final class ActionSheetView: AlertControllerView {

    @IBOutlet private var primaryView: UIView!
    @IBOutlet private weak var cancelActionView: UIView?
    @IBOutlet private weak var cancelLabel: UILabel?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private var contentViewConstraints: [NSLayoutConstraint]!
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var titleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabelFirstBaselineConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageLabelBaselineConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionsViewTopConstraint: NSLayoutConstraint!

    override var actionTappedHandler: ((AlertAction) -> Void)? {
        didSet { self.actionsCollectionView.actionTapped = self.actionTappedHandler }
    }

    override var visualStyle: AlertVisualStyle! {
        didSet {
            let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right
            self.titleWidthConstraint.constant -= widthOffset
        }
    }
    
    override var actionSheetShouldShowTitleAndMessage: Bool {
        didSet {
            self.actionsCollectionView.actionSheetShouldShowTitleAndMessage = self.actionSheetShouldShowTitleAndMessage
            
            self.titleLabelFirstBaselineConstraint.isActive = self.actionSheetShouldShowTitleAndMessage
            self.messageLabelBaselineConstraint.isActive = self.actionSheetShouldShowTitleAndMessage
            self.actionsViewTopConstraint.isActive = self.actionSheetShouldShowTitleAndMessage
        }
    }

    private var cancelAction: AlertAction? {
        didSet { self.cancelLabel?.attributedText = self.cancelAction?.attributedTitle }
    }

    override func prepareLayout() {
        super.prepareLayout()

        self.collectionViewHeightConstraint.constant = self.actionsCollectionView.displayHeight
        self.collectionViewHeightConstraint.isActive = true

        self.primaryView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.primaryView.layer.masksToBounds = true
        self.cancelActionView?.layer.cornerRadius = self.visualStyle.cornerRadius
        self.cancelActionView?.layer.masksToBounds = true

        self.cancelLabel?.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
        self.cancelLabel?.font = self.visualStyle.font(for: self.cancelAction)
        let cancelButtonBackground = UIImage.image(with: self.visualStyle.actionHighlightColor)
        self.cancelButton?.setBackgroundImage(cancelButtonBackground, for: .highlighted)
        self.cancelHeightConstraint.constant = self.visualStyle.actionViewSize.height
        
        if let cancelActionBgColor = self.visualStyle.actionSheetCancelActionBackgroundColor {
            self.cancelButton?.backgroundColor = cancelActionBgColor
        }

        let showContentView = self.contentView.subviews.count > 0
        self.contentView.isHidden = !showContentView
        self.contentViewConstraints.forEach { $0.isActive = showContentView }

        self.assignCancelAction()
    }

    override func highlightAction(for sender: UIPanGestureRecognizer) {
        super.highlightAction(for: sender)
        let cancelIsSelected = self.cancelActionView?.frame.contains(sender.location(in: self)) == true
        self.cancelButton?.isHighlighted = cancelIsSelected

        if cancelIsSelected && sender.state == .ended {
            self.cancelButton?.sendActions(for: .touchUpInside)
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.cancelLabel?.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
    }

    @IBAction private func cancelTapped() {
        guard let action = self.cancelAction else {
            return
        }

        self.actionTappedHandler?(action)
    }

    private func assignCancelAction() {
        if let cancelActionIndex = self.actions.index(where: { $0.style == .preferred }) {
            self.cancelAction = self.actions[cancelActionIndex]
            self.actions.remove(at: cancelActionIndex)
        } else {
            self.cancelAction = self.actions.first
            self.actions.removeFirst()
        }
    }
}

private extension UIImage {

    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
