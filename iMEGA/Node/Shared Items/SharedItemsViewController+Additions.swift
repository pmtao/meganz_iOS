import MEGADomain

extension SharedItemsViewController: ContatctsViewControllerDelegate {
    @objc func shareFolder() {
        if MEGAReachabilityManager.isReachableHUDIfNot() {
            guard let nodes = selectedNodesMutableArray as? [MEGANode] else { return }
            BackupNodesValidator(presenter: self, nodes: nodes.toNodeEntities()).showWarningAlertIfNeeded() { [weak self] in
                guard let `self` = self,
                        let navigationController = UIStoryboard(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "ContactsNavigationControllerID") as? MEGANavigationController,
                        let contactsVC = navigationController.viewControllers.first as? ContactsViewController else {
                    return
                }
                
                contactsVC.contatctsViewControllerDelegate = self
                contactsVC.nodesArray = nodes
                contactsVC.contactsMode = .shareFoldersWith
                
                self.present(navigationController, animated: true)
            }
        }
    }
}

//MARK: - Unverified outgoing and incoming nodes
extension SharedItemsViewController {
    @objc func indexPathFromSender(_ sender: UIButton) -> IndexPath? {
        let nonZeroPoint = CGPointMake(2, 2);
        let buttonPosition = sender.convert(nonZeroPoint, to: tableView)
        return tableView?.indexPathForRow(at: buttonPosition)
    }
    
    @objc func isFeatureFlagFingerprintVerificationEnabled() -> Bool {
        FeatureFlagProvider().isFeatureFlagEnabled(for: .mandatoryFingerprintVerification)
    }
    
    @objc func unverifiedIncomingSharedCellAtIndexPath(_ indexPath: IndexPath, node: MEGANode) -> SharedItemsTableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "sharedItemsTableViewCell", for: indexPath) as? SharedItemsTableViewCell else {
            return SharedItemsTableViewCell(style: .default, reuseIdentifier: "sharedItemsTableViewCell")
        }
        
        cell.delegate = self
        cell.thumbnailImageView.image = UIImage.mnz_incomingFolder()
        cell.nameLabel.textColor = UIColor.mnz_label()
        cell.nameLabel.text = Strings.Localizable.SharedItems.Tab.Incoming.undecryptedFolderName
        cell.nodeHandle = node.handle
        cell.permissionsButton.setImage(Asset.Images.SharedItems.warningPermission.image, for: .normal)
        cell.permissionsButton.isHidden = false
        
        if let user = userContactFromShareAtIndexPath(indexPath) {
            cell.infoLabel.text = user.mnz_displayName ?? user.email
        } else {
            cell.infoLabel.text = ""
        }
        
        setupLabelAndFavourite(for: node, cell: cell)
        configureAccessibility(for: cell)
        return cell
    }

    @objc func unverifiedOutgoingSharedCellAtIndexPath(_ indexPath: IndexPath, node: MEGANode) -> SharedItemsTableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "sharedItemsTableViewCell", for: indexPath) as? SharedItemsTableViewCell else {
            return SharedItemsTableViewCell(style: .default, reuseIdentifier: "sharedItemsTableViewCell")
        }
        
        cell.delegate = self
        cell.thumbnailImageView.image = UIImage.mnz_outgoingFolder()
        cell.nodeHandle = node.handle
        cell.nameLabel.text = node.name
        cell.nameLabel.textColor = UIColor.mnz_red(for: self.traitCollection)
        cell.permissionsButton.setImage(Asset.Images.SharedItems.warningPermission.image, for: .normal)
        cell.permissionsButton.isHidden = false
        
        if let user = userContactFromShareAtIndexPath(indexPath) {
            let userName: String = user.mnz_displayName ?? user.email
            cell.infoLabel.text = Strings.Localizable.SharedItems.Tab.Outgoing.sharedToContact(userName)
        } else {
            cell.infoLabel.text = ""
        }
        
        setupLabelAndFavourite(for: node, cell: cell)
        configureAccessibility(for: cell)
        return cell
    }
    
    @objc func userContactFromShareAtIndexPath(_ indexPath: IndexPath) -> MEGAUser? {
        guard let share = shareAtIndexPath(indexPath) else { return nil }
        return MEGASdk.shared.contact(forEmail: share.user)
    }
    
    @objc func shareAtIndexPath(_ indexPath: IndexPath) -> MEGAShare? {
        guard indexPath.section == 0 else { return nil }
        
        if outgoingButton?.isSelected == true {
            return outgoingUnverifiedSharesMutableArray?[indexPath.row] as? MEGAShare
        }
        
        if incomingButton?.isSelected == true {
            return incomingUnverifiedSharesMutableArray?[indexPath.row] as? MEGAShare
        }
        
        return nil
    }
    
    @objc func shouldShowContactVerificationOnTap(forIndexPath indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0, let share = shareAtIndexPath(indexPath) else { return false }
        return !share.isVerified
    }

    @objc func numberOfSections() -> Int {
        guard linksButton?.isSelected == true else {
            return 2
        }
        return 1
    }
    
    private func shares(from shareList: MEGAShareList) -> [MEGAShare] {
        (0..<shareList.size.intValue).compactMap { index in
            let share: MEGAShare = shareList.share(at: index)
            guard share.user != nil else { return nil }
            return share
        }
    }
    
    private func nodes(from shares: [MEGAShare]) -> [MEGANode] {
        shares.compactMap { share in
            MEGASdk.shared.node(forHandle: share.nodeHandle)
        }
    }
    
    private func badgeValue(_ count: Int) -> String {
        count == 0 ? "" : String(count)
    }
    
    @objc func outgoingUnverifiedNodes() {
        let shareList = MEGASdk.shared.getUnverifiedOutShares(sortOrderType)
        outgoingUnverifiedSharesMutableArray?.removeAllObjects()
        outgoingUnverifiedNodesMutableArray?.removeAllObjects()
        
        let shares = shares(from: shareList)
        outgoingUnverifiedSharesMutableArray?.addObjects(from: shares)

        let nodes = nodes(from: shares)
        outgoingUnverifiedNodesMutableArray?.addObjects(from: nodes)

        outgoingButton?.setBadgeCount(value: badgeValue(shares.count))
    }
    
    @objc func incomingUnverifiedNodes() {
        let shareList = MEGASdk.shared.getUnverifiedInShares(sortOrderType)
        incomingUnverifiedSharesMutableArray?.removeAllObjects()
        incomingUnverifiedNodesMutableArray?.removeAllObjects()
        
        let shares = shares(from: shareList)
        incomingUnverifiedSharesMutableArray?.addObjects(from: shares)
        
        let nodes = nodes(from: shares)
        incomingUnverifiedNodesMutableArray?.addObjects(from: nodes)
        
        incomingButton?.setBadgeCount(value: badgeValue(shares.count))
    }
}

//MARK: - SharedItemsTableViewCellDelegate
extension SharedItemsViewController: SharedItemsTableViewCellDelegate {
        
    func didTapInfoButton(sender: UIButton) {
        showNodeContextMenu(sender)
    }
}
