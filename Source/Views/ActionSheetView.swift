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

    override var actions: [AlertAction] {
        didSet {
            if let cancelActionIndex = self.actions.indexOf({ $0.style == .Preferred }) {
                self.cancelAction = self.actions[cancelActionIndex]
                self.actions.removeAtIndex(cancelActionIndex)
            }
        }
    }

    override var actionTappedHandler: (AlertAction -> Void)? {
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
            
            self.titleLabelFirstBaselineConstraint.active = self.actionSheetShouldShowTitleAndMessage
            self.messageLabelBaselineConstraint.active = self.actionSheetShouldShowTitleAndMessage
            self.actionsViewTopConstraint.active = self.actionSheetShouldShowTitleAndMessage
        }
    }

    private var cancelAction: AlertAction? {
        didSet { self.cancelLabel?.attributedText = self.cancelAction?.attributedTitle }
    }

    override func prepareLayout() {
        super.prepareLayout()

        self.collectionViewHeightConstraint.constant = self.actionsCollectionView.displayHeight
        self.collectionViewHeightConstraint.active = true

        self.primaryView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.primaryView.layer.masksToBounds = true
        self.cancelActionView?.layer.cornerRadius = self.visualStyle.cornerRadius
        self.cancelActionView?.layer.masksToBounds = true

        self.cancelLabel?.textColor = self.visualStyle.textColor(forAction: self.cancelAction) ?? self.tintColor
        self.cancelLabel?.font = self.visualStyle.font(forAction: self.cancelAction)
        let cancelButtonBackground = UIImage.imageWithColor(self.visualStyle.actionHighlightColor)
        self.cancelButton?.setBackgroundImage(cancelButtonBackground, forState: .Highlighted)
        self.cancelHeightConstraint.constant = self.visualStyle.actionViewSize.height
        
        if let cancelActionBgColor = self.visualStyle.actionSheetCancelActionBackgroundColor {
            self.cancelButton?.backgroundColor = cancelActionBgColor
        }

        let showContentView = self.contentView.subviews.count > 0
        self.contentView.hidden = !showContentView
        self.contentViewConstraints.forEach { $0.active = showContentView }
        
        self.titleLabel.hidden = true
        self.messageLabel.hidden = true
    }

    override func highlightActionForPanGesture(sender: UIPanGestureRecognizer) {
        super.highlightActionForPanGesture(sender)
        let cancelIsSelected = self.cancelActionView?.frame.contains(sender.locationInView(self)) == true
        self.cancelButton?.highlighted = cancelIsSelected

        if cancelIsSelected && sender.state == .Ended {
            self.cancelButton?.sendActionsForControlEvents(.TouchUpInside)
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.cancelLabel?.textColor = self.visualStyle.textColor(forAction: self.cancelAction) ?? self.tintColor
    }

    @IBAction private func cancelTapped() {
        guard let action = self.cancelAction else { return }
        self.actionTappedHandler?(action)
    }
}

private extension UIImage {

    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
