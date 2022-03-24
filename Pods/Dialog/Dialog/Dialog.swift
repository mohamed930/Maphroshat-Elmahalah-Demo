//
//  Dialog.swift
//  Meniny
//
//  Created by Meniny on 12/11/16.
//  Copyright © 2016 Meniny. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
open class Dialog: UIViewController {
    
    public typealias ActionHandler = ((_ dialog: Dialog) -> (Swift.Void))
    public typealias VoidClosure = (() -> Swift.Void)
    public typealias VoidButtonClosure = ((_ button: UIButton) -> Swift.Void)
    public typealias BooleanButtonClosure = ((_ button: UIButton) -> Swift.Bool)
    
    public enum DismissDirection {
        case top, bottom, both, none
    }
    
    public struct Action {
        public var title: String?
        public var isEnabled: Bool = true
        public var handler: Dialog.ActionHandler?
        
        public init(title: String, handler: Dialog.ActionHandler? = nil) {
            self.title = title
            self.handler = handler
        }
    }

    //MARK: - Private Properties
    
    /// The container that holds the image view.
    fileprivate var imageViewHolder: UIView = UIView()
    
    /// The image view.
    fileprivate var imageView: UIImageView = UIImageView()
    
    /// The Title Label.
    fileprivate var titleLabel: UILabel = UILabel()
    
    /// The message label.
    fileprivate var messageLabel: UILabel = UILabel()
    
    /// The cancel button.
    fileprivate var cancelButton: UIButton = UIButton(type: .system)
    
    /// The stackview that holds the buttons.
    fileprivate var buttonsStackView: UIStackView = UIStackView()
    
    /// The stack that holds all the view
    fileprivate var generalStackView: UIStackView = UIStackView()
    
    /// The seperatorView
    fileprivate var separatorView: UIView = UIView()
    
    /// The button on the left
    fileprivate var leftToolItem: UIButton = UIButton(type: .system)
    
    /// The button on the right
    fileprivate var rightToolItem: UIButton = UIButton(type: .system)
    
    /// The array which holds the actions
    open var actions: [Dialog.Action] = []
    
    /// The primary draggable view.
    fileprivate var baseView: BaseView = BaseView()
    
    /// Did finish animating
    fileprivate var didInitAnimation = false
    
    /// The view holder's top anchor constraint
    fileprivate var imageViewHolderConstraint: NSLayoutConstraint!
    
    /// The image view holder's height constraint
    fileprivate var imageViewHolderHeightConstraint: NSLayoutConstraint!
    
    /// The general stack view top constraint
    fileprivate var generalStackViewTopConstraint: NSLayoutConstraint!
    
    /// The cancel button constraint
    fileprivate var cancelButtonHeightConstraint: NSLayoutConstraint! {
        willSet {
            if cancelButtonHeightConstraint != nil {
                cancelButtonHeightConstraint.isActive = false
            }
        } didSet {
            cancelButtonHeightConstraint.isActive = true
        }
    }
    
    //The height constraint of the custom view `container`
    fileprivate var customViewHeightAnchor: NSLayoutConstraint! {
        willSet {
            if customViewHeightAnchor != nil { customViewHeightAnchor.isActive = false }
        } didSet {
            customViewHeightAnchor.isActive = true
        }
    }
    
    // Title of the dialog.
    fileprivate var dialogTitle: String?{
        didSet {
            titleLabel.text = dialogTitle
            if dialogTitle == nil || dialogTitle?.count == 0{
                titleLabel.isHidden = true
                separatorView.isHidden = true
            } else {
                titleLabel.isHidden = false
                separatorView.isHidden = false
            }
            animateStackView()
        }
    }
    
    // Message of the dialog.
    fileprivate var dialogMessage: String?{
        didSet {
            messageLabel.text = dialogMessage
            if dialogMessage == nil || dialogMessage?.count == 0{
                messageLabel.isHidden = true
            } else {
                messageLabel.isHidden = false
            }
            animateStackView()
        }
    }
    
    // Helper to get the real device width
    fileprivate var deviceWidth: CGFloat {
        return view.bounds.width < view.bounds.height ? view.bounds.width : view.bounds.height
    }
    
    // Helper to get the real device height
    fileprivate var deviceHeight: CGFloat {
        return view.bounds.width < view.bounds.height ? view.bounds.height : view.bounds.width
    }
    
    //MARK: - Getters
    
    open fileprivate(set) var spacing: CGFloat = -1
    
    open fileprivate(set) var stackSpacing: CGFloat = 8
    
    open fileprivate(set) var sideSpacing: CGFloat = 20
    
    open fileprivate(set) var buttonHeight: CGFloat = 0
    
    open fileprivate(set) var cancelButtonHeight: CGFloat = 0
    
    open fileprivate(set) var titleFontSize: CGFloat = 0
    
    open fileprivate(set) var messageFontSize: CGFloat = 0
    
    public static let defaultFontName: String = "AvenirNext-Medium"
    
    public static let defaultBoldFontName: String = "AvenirNext-DemiBold"
    
    open fileprivate(set) var fontName: String = Dialog.defaultFontName
    
    open fileprivate(set) var boldFontName: String = Dialog.defaultBoldFontName
    
    open fileprivate(set) lazy var container: UIView = UIView()
    
    //MARK: - Public
    
    /// Show separator
    open var showSeparator = true
    
    /// Separator Color
    open var separatorColor: UIColor = UIColor(displayP3Red: 208/255, green: 211/255, blue: 214/255, alpha: 1) {
        didSet {
            separatorView.backgroundColor = separatorColor
        }
    }
    
    /// Allow dismiss when touching outside of the dialog (touching the background)
    open var dismissWithOutsideTouch = true
    
    /// Allow users to drag the dialog
    open var allowDragGesture = true
    
    /// Button style closure, called when setting up an action. Where the 1st parameter is a reference to the button, the 2nd is the height of the button and the 3rd is the index of the button.
    open var buttonStyle: ((_ button: UIButton,_ height: CGFloat, _ index: Int) -> Void)?
    
    /// Left Tool Style, is the style (closure) that is called when setting up the left tool item. Make sure to return true to show the item.
    open var leftToolStyle:  Dialog.BooleanButtonClosure?
    
    /// Right Tool Style, is the style (closure) that is called when setting up the right tool item. Make sure to return true to show the item.
    open var rightToolStyle:  Dialog.BooleanButtonClosure?
    
    /// The action that is triggered when tool is clicked.
    open var leftToolAction:  Dialog.VoidButtonClosure?
    
    /// The action that is triggered when tool is clicked.
    open var rightToolAction: Dialog.VoidButtonClosure?
    
    /// The cancel button style. where @UIButton is the refrence to the button, @CGFloat is the height of the button and @Bool is the value you return where true would show the button and false won't.
    open var cancelButtonStyle: ((_ button: UIButton, _ height: CGFloat) -> Bool)?
    
    /// Image handler, used when setting up an image using some sort of process.
    open var imageHandler: ((_ imageView: UIImageView) -> Bool)?
    
    /// Dismiss direction [top,bottom,both,none]
    open var dismissDirection: Dialog.DismissDirection = .both
    
    /// Background alpha. default is 0.2
    open var backgroundAlpha: Float = 0.2
    
    open var animationDuration: TimeInterval = 0.2
    
    /// Change the title of the dialog
    open override var title: String? {
        get {
            return dialogTitle
        }
        set {
            dialogTitle = newValue
        }
    }
    
    /// Change the message of the dialog
    open var message: String? {
        get {
            return dialogMessage
        } set {
            dialogMessage = newValue
        }
    }
    
    /// Change the height of the custom view
    open var customViewSizeRatio: CGFloat = 0 {
        didSet {
            customViewHeightAnchor =
                container.heightAnchor
                    .constraint(equalTo: container.widthAnchor, multiplier: customViewSizeRatio)
            
            let alpha: CGFloat = customViewSizeRatio > 0 ? 1.0 : 0
            animateStackView(withOptionalAnimations:  { [weak self] in
                self?.container.alpha = alpha
            })
        }
    }
    
    public static let defaultCancelTitle = "CANCEL"
    
    /// Change the text of the cancel button
    open var cancelTitle: String = Dialog.defaultCancelTitle {
        didSet {
            cancelButton.setTitle(cancelTitle, for: .normal)
        }
    }
    
    /// Use this to hide/show the cancel button
    open var cancelEnabled: Bool = false {
        willSet {
            //design the button if possible
            if newValue, cancelButtonHeight != 0  {
                _ = cancelButtonStyle?(cancelButton, cancelButtonHeight)
            }
            
        }
        didSet {
            //update the height constraint
            cancelButtonHeightConstraint =
                cancelButton.heightAnchor
                    .constraint(equalToConstant: cancelButtonHeight * (cancelEnabled ? 1.0 : 0.0))
            
            //animate with alpha
            let alpha: CGFloat = (cancelEnabled ? 1.0 : 0.0)
            
            //copy values for use in closure
            let newValue = cancelEnabled
            if newValue {
                cancelButton.isHidden = false
            }
            
            //animate stack view with completion block and additional animations
            animateStackView(completionBlock: { [weak self] in
                if !newValue {
                    self?.cancelButton.isHidden = true
                }
                
            }) {[weak self] in
                self?.cancelButton.alpha = alpha
                
            }
        }
    }
    
    open var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            if let image = newValue {
                //not nil
                if let _ = imageView.image {
                    // old value not nil
                    //new value not nil
                    //only update the image
                    imageView.image = image
                } else {
                    //old nil
                    //new value not nil
                    //update image and constraints
                    imageView.image = image
                    updateConstraints(showImage: true)
                }
            } else {
                //nil
                if let _ = imageView.image {
                    //old value not nil
                    updateConstraints(showImage: false) { [weak self] in
                        self?.imageView.image = nil
                    }
                    
                }
            }
            
            
        }
    }
    
    // MARK: - initializer
    
    /// Primary initializer
    ///
    /// - Parameters:
    ///   - title: The title that will be set on the dialog.
    ///   - message: The message that will be set on the dialog.
    ///   - image: The Image that will be set on the dialog.
    public convenience init(title: String,
                            message: String,
                            image: UIImage? =  nil) {
        self.init(nibName: nil, bundle: nil)
        
        self.dialogTitle = title
        self.dialogMessage = message
        self.image = image
    }
    
    public var loadingIndicator: UIActivityIndicatorView?
    
    /// Configuration
    ///
    /// - Parameters:
    ///   - spacing: The vertical spacing between views.
    ///   - stackSpacing: The vertical spacing between the buttons.
    ///   - sideSpacing: The spacing on the side of the views (Between the views and the base dialog view)
    ///   - titleFontSize: The title font size.
    ///   - messageFontSize: The message font size.
    ///   - buttonsHeight: The buttons' height.
    ///   - cancelButtonHeight: The cancel button height.
    ///   - fontName: The font name that will be used for the message label and the buttons.
    ///   - boldFontName: The font name that will be used for the title.
    public func config(verticalSpacing spacing: CGFloat = -1,
                       buttonSpacing stackSpacing:CGFloat = 10,
                       sideSpacing: CGFloat = 20,
                       titleFontSize: CGFloat = 0,
                       messageFontSize: CGFloat = 0,
                       buttonsHeight: CGFloat = 0,
                       cancelButtonHeight: CGFloat = 0,
                       fontName: String = Dialog.defaultFontName,
                       boldFontName: String = Dialog.defaultBoldFontName) -> Dialog {
        self.spacing = spacing
        self.stackSpacing = stackSpacing
        self.sideSpacing = sideSpacing
        self.titleFontSize = titleFontSize
        self.messageFontSize = messageFontSize
        self.buttonHeight = buttonsHeight
        self.cancelButtonHeight = cancelButtonHeight
        self.fontName = fontName
        self.boldFontName = boldFontName
        return self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupStyles()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView() {
        super.loadView()
        imageViewHolder.backgroundColor = .white
        
        if spacing == -1 {
            spacing = deviceHeight * 0.012
        }
        let showImage = imageHandler == nil ? (imageView.image != nil) : (imageHandler?(imageView) ?? false)
        
        // Disable translate auto resizing mask into constraints
        baseView.translatesAutoresizingMaskIntoConstraints = false
        generalStackView.translatesAutoresizingMaskIntoConstraints = false
        imageViewHolder.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        leftToolItem.translatesAutoresizingMaskIntoConstraints = false
        rightToolItem.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(baseView)
        baseView.addSubview(generalStackView)
        baseView.addSubview(imageViewHolder)
        baseView.addSubview(cancelButton)
        generalStackView.addArrangedSubview(titleLabel)
        generalStackView.addArrangedSubview(separatorView)
        generalStackView.addArrangedSubview(messageLabel)
        generalStackView.addArrangedSubview(container)
        generalStackView.addArrangedSubview(buttonsStackView)
        imageViewHolder.addSubview(imageView)
        
        
        //setup image
        let imageMultiplier = setupImage(showImage: showImage)
        
        //Setup general stack view
        setupGeneralStackView(imageMultiplier: imageMultiplier)
        
        // Setup Title Label
        setupTitleLabel()
        
        // Setup Seperator Line
        setupSeparator()
        
        // Setup Message Label
        setupMessageLabel()

        //Setup Custom View
        setupContainer()
        
        // Setup Buttons (StackView)
        setupButtonsStack()
        
        // Setup Cancel button
        setupCancelButton()
        
        // Setup Base View
        setupBaseView()

        // Setup Tool Items
        setupToolItems()
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Dialog.handleTapGesture(_:))))
        baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Dialog.handleTapGesture(_:))))
        baseView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(Dialog.handlePanGesture(_:))))
        baseView.layer.cornerRadius = 15
        baseView.layer.backgroundColor = UIColor.white.cgColor
        baseView.isHidden = true
        baseView.lastLocation = self.view.center
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didInitAnimation{
            didInitAnimation = true
            baseView.center.y = self.view.bounds.maxY + baseView.bounds.midY
            baseView.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6.0, options: [], animations: { [weak self]() -> Void in
                if let `self` = self {
                    self.baseView.center = self.view.center
                    let backgroundColor = UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: self.backgroundAlpha)
                    self.view.backgroundColor = backgroundColor
                }
            })
        }
    }
    
    // MARK: - Handlers
    
    /// Selector method - used to handle the dragging.
    ///
    /// - Parameter sender: The Gesture Recognizer.
    @objc internal func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        if !allowDragGesture{ return }
        
        let animationDuration = self.animationDuration
        
        let translation = sender.translation(in: self.view)
        baseView.center = CGPoint(x: baseView.lastLocation.x , y: baseView.lastLocation.y + translation.y)
        
        let returnToCenter:(CGPoint,Bool) -> Void = { (finalPoint,animate) in
            if !animate {
                self.baseView.center = finalPoint
                return
            }
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2.0, options: [], animations: {[weak self] () -> Void in
                self?.baseView.center = finalPoint
            }, completion: nil)
        }
        
        let dismissInDirection:(CGPoint) -> Void = { [weak self] (finalPoint) in
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                self?.baseView.center = finalPoint
                self?.view.backgroundColor = .clear
            }, completion: { (complete) -> Void in
                self?.dismiss(animated: false, completion: nil)
            })
        }
        
        var finalPoint = view.center
        
        if sender.state == .ended{
            
            let velocity = sender.velocity(in: view)
            let mag = sqrtf(Float(velocity.x * velocity.x) + Float(velocity.y * velocity.y))
            let slideMult = mag / 200
            let dismissWithGesture = (dismissDirection != .none)
            
            
            
            if dismissWithGesture && slideMult > 1 {
                //dismiss
                if velocity.y > 0{
                    //dismiss downward
                    if dismissDirection == .bottom || dismissDirection == .both {
                        finalPoint.y = view.frame.maxY + (baseView.bounds.midY)
                        dismissInDirection(finalPoint)
                    } else {
                        returnToCenter(finalPoint, true)
                    }
                } else {
                    
                    //dismiss upward
                    if dismissDirection == .top || dismissDirection == .both {
                        finalPoint.y = -(baseView.bounds.midY)
                        dismissInDirection(finalPoint)
                    } else {
                        returnToCenter(finalPoint, true)
                    }
                }
            } else {
                //return to center
                returnToCenter(finalPoint, true)
            }
        }
        
        if sender.state == .cancelled || sender.state == .failed {
            returnToCenter(finalPoint, false)
        }
    }
    
    /// Selector method - used to handle view touch.
    ///
    /// - Parameter sender: The Gesture Recognizer.
    @objc internal func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.view is BaseView{
            return
        }
        if dismissWithOutsideTouch{
            self.dismiss()
        }
    }
    
    /// Selector method - used when cancel button is clicked.
    ///
    /// - Parameter sender: The cancel button.
    @objc internal func cancelAction(_ sender: UIButton) {
        dismiss()
    }
    
    /// Selector method - used when left tool item button is clicked.
    ///
    /// - Parameter sender: The left tool button.
    @objc internal func handleLeftTool(_ sender: UIButton) {
        leftToolAction?(sender)
    }
    
    /// Selector method - used when right tool item button is clicked.
    ///
    /// - Parameter sender: The right tool button.
    @objc internal func handleRightTool(_ sender: UIButton) {
        rightToolAction?(sender)
    }

    /// Selector method - used when one of the action buttons are clicked.
    ///
    /// - Parameter sender: Action Button
    @objc internal func handleAction(_ sender: UIButton) {
        if sender.tag >= 0 && sender.tag < actions.count {
            (actions[sender.tag].handler)?(self)
        }
    }
}

extension Dialog {
    
    /// Add an action button to the dialog. Make sure you add the actions before calling the .show() function.
    ///
    /// - Parameter action: The Dialog.Action.
    open func addAction(title: String, handler: Dialog.ActionHandler? = nil) {
        addAction(Dialog.Action(title: title, handler: handler))
    }
    
    /// Add an action button to the dialog. Make sure you add the actions before calling the .show() function.
    ///
    /// - Parameter action: The Dialog.Action.
    open func addAction(_ action: Dialog.Action) {
        actions.append(action)
        
        let button = setupButton(index: actions.count - 1)
        self.buttonsStackView.addArrangedSubview(button)
        //button.frame = buttonsStackView.bounds
        button.center = CGPoint(x: buttonsStackView.bounds.midX, y: buttonsStackView.bounds.maxY)
        updateTags()
        animateStackView()
    }
    
    
    /// Remove a button at a certain index.
    ///
    /// - Parameter index: The index at which you would like to remove the action.
    open func removeAction(at index: Int) {
        if actions.count <= index {
            return
        }
        
        actions.remove(at: index)
        
        for subview in buttonsStackView.arrangedSubviews {
            if subview.tag == index {
                subview.removeFromSuperview()
            }
        }
        
        updateTags()
        
        animateStackView()
    }
    
    fileprivate func updateTags() {
        var i = 0
        for view in buttonsStackView.arrangedSubviews {
            view.tag = i
            i += 1
        }
    }
    
    
    /// Remove all actions
    open func removeAllActions() {
        actions.removeAll()
        
        for view in buttonsStackView.arrangedSubviews{
            view.removeFromSuperview()
        }
        
        animateStackView()
    }
}

fileprivate extension Dialog {
    
    /// Helper function to change the dialog using an animation
    ///
    /// - Parameters:
    ///   - completionBlock: Block that is executed once aniamtions are finished.
    ///   - animations: Additional animations to execute.
    func animateStackView(completionBlock: Dialog.VoidClosure? = nil,
                                      withOptionalAnimations animations: Dialog.VoidClosure? = nil) {
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            animations?()
            self?.generalStackView.setNeedsLayout()
            self?.generalStackView.layoutIfNeeded()
            self?.baseView.setNeedsLayout()
            self?.baseView.layoutIfNeeded()
        }) { (bool) in
            completionBlock?()
        }
    }

    /// Helper function to update the constraints
    ///
    /// - Parameters:
    ///   - showImage: shows the image if true
    ///   - completion: completion block, to execute after the animation
    func updateConstraints(showImage: Bool, completion: Dialog.VoidClosure? = nil) {
        
        //update constraints only if they already exists.
        if generalStackViewTopConstraint == nil || imageViewHolderConstraint == nil || imageViewHolderHeightConstraint == nil{
            return
        }
        
        //remove existing constraint
        generalStackViewTopConstraint.isActive = false
        imageViewHolderConstraint.isActive = false
        imageViewHolderHeightConstraint.isActive = false
        
        
        //update constraints
        let imageHolderSize: CGFloat = CGFloat(Int((deviceWidth - 2 * deviceWidth / 8) / 3))
        let constant = showImage ? imageHolderSize : 0.0
        
        generalStackViewTopConstraint =
            generalStackView
                .topAnchor.constraint(equalTo: imageViewHolder.bottomAnchor, constant: spacing + spacing * (showImage ? 0.0 : 1.0))
        
        generalStackViewTopConstraint.isActive = true
        
        imageViewHolderConstraint =
            imageViewHolder.topAnchor.constraint(equalTo: baseView.topAnchor, constant: -constant/3)
        imageViewHolderConstraint.isActive = true
        
        imageViewHolderHeightConstraint = imageViewHolder.heightAnchor.constraint(equalToConstant: constant)
        imageViewHolderHeightConstraint.isActive = true
        
        //setup layers
        imageViewHolder.layer.cornerRadius = imageHolderSize / 2
        imageViewHolder.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = (imageHolderSize - 2 * 5) / 2
        imageView.layer.masksToBounds = true
        
        //setup transform
        let transform = showImage ? CGAffineTransform(scaleX: 0, y: 0) : .identity
        imageViewHolder.transform = transform
        imageView.transform = transform
        
        //animate changes
        animateStackView(completionBlock: {
            completion?()
        }) { [weak self] in
            
            self?.imageViewHolder.alpha = showImage ? 1.0 : 0.0
            let inverseTransform = showImage ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
            self?.imageViewHolder.transform = inverseTransform
            self?.imageView.transform = inverseTransform
        }
        
    }
}

// MARK: - Setup
fileprivate extension Dialog {
    /// Setup Image View
    func setupImage(showImage: Bool) -> CGFloat {
        let imageHolderSize: CGFloat = showImage ? CGFloat(Int((deviceWidth - 2 * deviceWidth / 8) / 3))  : 0
        let imageMultiplier:CGFloat = showImage ? 0.0 : 1.0
        imageViewHolder.layer.cornerRadius = imageHolderSize / 2
        imageViewHolder.layer.masksToBounds = true
        imageViewHolder.backgroundColor = UIColor.white
        
        imageViewHolder.centerXAnchor.constraint(equalTo: baseView.centerXAnchor, constant: 0).isActive = true
        
        imageViewHolder.widthAnchor.constraint(equalTo: imageViewHolder.heightAnchor).isActive = true
        
        imageViewHolderConstraint = imageViewHolder.topAnchor.constraint(equalTo: baseView.topAnchor, constant: -imageHolderSize/3)
        imageViewHolderConstraint.isActive = true
        
        imageViewHolderHeightConstraint = imageViewHolder.heightAnchor.constraint(equalToConstant: imageHolderSize)
        imageViewHolderHeightConstraint.isActive = true
        
        imageView.layer.cornerRadius = (imageHolderSize - 2 * 5) / 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        /*
         
         imageView.topAnchor.constraint(equalTo: imageViewHolder.topAnchor, constant: 5).isActive = true
         imageView.rightAnchor.constraint(equalTo: imageViewHolder.rightAnchor, constant: -5).isActive = true
         imageView.leftAnchor.constraint(equalTo: imageViewHolder.leftAnchor, constant: 5).isActive = true
         imageView.bottomAnchor.constraint(equalTo: imageViewHolder.bottomAnchor, constant: -5).isActive = true
         */
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageViewHolder.widthAnchor, multiplier: 0.90).isActive = true
        imageView.centerXAnchor.constraint(equalTo: imageViewHolder.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: imageViewHolder.centerYAnchor).isActive = true
        
        return imageMultiplier
    }
    
    /// Setup general stack view
    func setupGeneralStackView(imageMultiplier: CGFloat) {
        generalStackView.distribution = .fill
        generalStackView.alignment = .center
        generalStackView.axis = .vertical
        generalStackView.spacing = stackSpacing
        
        generalStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        generalStackView.leftAnchor.constraint(equalTo: baseView.leftAnchor,constant: sideSpacing/2).isActive = true
        generalStackView.rightAnchor.constraint(equalTo: baseView.rightAnchor,constant: -sideSpacing/2).isActive = true
        
        generalStackViewTopConstraint =
            generalStackView.topAnchor.constraint(equalTo: imageViewHolder.bottomAnchor, constant: spacing + spacing * imageMultiplier)
        generalStackViewTopConstraint.isActive = true
    }
    
    /// Setup Title Label
    func setupTitleLabel() {
        
        if titleFontSize == 0 {titleFontSize = deviceHeight * 0.0269}
        let titleFont = UIFont(name: boldFontName, size: titleFontSize)
        //let titleHeight:CGFloat = dialogTitle == nil ? 0 : heightForView(dialogTitle!, font: titleFont!, width: deviceWidth * 0.6)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.text = dialogTitle
        titleLabel.font = titleFont
        titleLabel.textAlignment = .center
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: messageLabel.widthAnchor, multiplier: 1.0).isActive = true
        //titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: titleHeight).isActive = true
    }
    
    /// Setup Seperator Line
    func setupSeparator() {
        let seperatorHeight: CGFloat = self.showSeparator ? 0.7 : 0
        //TODO: make the color a customizable var
        separatorView.backgroundColor = separatorColor
        separatorView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 1.0).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: seperatorHeight).isActive = true
    }
    
    /// Setup Message Label
    func setupMessageLabel() {
        if messageFontSize == 0 {
            messageFontSize = deviceHeight * 0.0239
        }
        let labelFont = UIFont(name: fontName, size: messageFontSize)!
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.font = labelFont
        messageLabel.text = dialogMessage
        messageLabel.textAlignment = .center
    }
    
    /// Setup Custom View
    func setupContainer() {
        container.alpha = customViewSizeRatio > 0 ? 1.0 : 0.0
        container.widthAnchor.constraint(equalTo: generalStackView.widthAnchor, multiplier: 1.0).isActive = true
        customViewHeightAnchor = container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: customViewSizeRatio)
    }
    
    /// Setup Buttons (StackView)
    func setupButtonsStack() {
        
        //let stackViewSize: Int = self.actions.count * Int(buttonHeight) + (self.actions.count-1) * Int(stackSpacing)
        
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .fill
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = stackSpacing
        //buttonsStackView.heightAnchor.constraint(equalToConstant: CGFloat(stackViewSize)).isActive = true
        buttonsStackView.widthAnchor.constraint(equalTo: generalStackView.widthAnchor, multiplier: 0.8).isActive = true
        
//        for i in 0 ..< actions.count {
//            let button = setupButton(index: i)
//            buttonsStackView.addArrangedSubview(button)
//        }
    }
    
    func setupButton(index i: Int) -> UIButton {
        if buttonHeight == 0 {
            buttonHeight = deviceHeight * 0.07
        }
        let button = UIButton(type: .custom)
        let action = actions[i]
        button.isExclusiveTouch = true
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(button.tintColor, for: .normal)
        button.layer.borderColor = button.tintColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = buttonHeight/2
        button.titleLabel?.font = UIFont(name: fontName, size: buttonHeight * 0.35)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        self.buttonStyle?(button,buttonHeight,i)
        button.tag = i
        button.addTarget(self, action: #selector(Dialog.handleAction(_:)), for: .touchUpInside)
        return button
    }
    
    /// Setup Cancel Button
    func setupCancelButton() {
        if cancelButtonHeight == 0 {
            cancelButtonHeight = deviceHeight * 0.0449
        }
        cancelButton.setTitle(cancelTitle, for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: fontName, size: cancelButtonHeight * 0.433)
        let showCancelButton = (cancelButtonStyle?(cancelButton,cancelButtonHeight) ?? false) && cancelEnabled
        let cancelMultiplier: CGFloat = showCancelButton ? 1.0 : 0
        cancelButton.isHidden = (showCancelButton ? cancelButtonHeight : 0) <= 0
        cancelButton.topAnchor.constraint(equalTo: generalStackView.bottomAnchor,constant: spacing).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: baseView.bottomAnchor,constant: -spacing).isActive = true
        
        cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonHeight  * cancelMultiplier)
        cancelButton.addTarget(self, action: #selector(Dialog.cancelAction(_:)), for: .touchUpInside)
    }
    
    /// Setup BaseView
    func setupBaseView() {
        self.baseView.isExclusiveTouch = true
        baseView.widthAnchor.constraint(equalToConstant: deviceWidth * 0.7).isActive = true
        baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 0).isActive = true
        baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: 0).isActive = true
        //baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: deviceWidth * 0.5).isActive = true
    }
    
    // Setup Tool Items
    func setupToolItems() {
        if leftToolStyle?(leftToolItem) ?? false {
            baseView.addSubview(leftToolItem)
            leftToolItem.topAnchor.constraint(equalTo: baseView.topAnchor, constant: spacing * 2).isActive = true
            leftToolItem.leftAnchor.constraint(equalTo: baseView.leftAnchor,constant: spacing * 2).isActive = true
            leftToolItem.widthAnchor.constraint(equalTo: leftToolItem.heightAnchor).isActive = true
            leftToolItem.addTarget(self, action: #selector(Dialog.handleLeftTool(_:)), for: .touchUpInside)
        }
        
        if rightToolStyle?(rightToolItem) ?? false {
            baseView.addSubview(rightToolItem)
            rightToolItem.topAnchor.constraint(equalTo: baseView.topAnchor, constant: spacing * 2).isActive = true
            rightToolItem.rightAnchor.constraint(equalTo: baseView.rightAnchor,constant: -spacing * 2).isActive = true
            rightToolItem.widthAnchor.constraint(equalTo: rightToolItem.heightAnchor).isActive = true
            rightToolItem.heightAnchor.constraint(equalToConstant: 20).isActive = true
            rightToolItem.addTarget(self, action: #selector(Dialog.handleRightTool(_:)), for: .touchUpInside)
        }
    }
    
    func setupStyles() {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
}

extension Dialog {
    
    /// The primary fuction to present the dialog.
    ///
    /// - Parameter controller: The View controller in which you wish to present the dialog.
    public func show(in controller: UIViewController) {
        if let _ = loadingIndicator {
            loadingIndicator?.startAnimating()
        }
        controller.present(self, animated: false, completion: nil)
    }
    
    //MARK: - Overriding methods
    
    /// The primary function to dismiss the dialog.
    ///
    /// - Parameters:
    ///   - animated: Should it dismiss with animation? default is true.
    ///   - completion: Completion block that is called after the controller is dismiss.
    override open func dismiss(animated: Bool = true, completion: Dialog.VoidClosure? = nil) {
        if let _ = loadingIndicator {
            loadingIndicator?.stopAnimating()
        }
        if animated {
            UIView.animate(withDuration: animationDuration, animations: { [weak self] () -> Void in
                if let `self` = self{
                    self.baseView.center.y = self.view.bounds.maxY + (self.baseView.bounds.midY)
                    self.view.backgroundColor = .clear
                }
                }, completion: { (complete) -> Void in
                    super.dismiss(animated: false, completion: completion)
            })
        } else {
            super.dismiss(animated: false, completion: completion)
        }
    }
}

public extension UIViewController {
    
    /// Primary initializer
    ///
    /// - Parameters:
    ///   - title: The title that will be set on the dialog.
    ///   - message: The message that will be set on the dialog.
    ///   - image: The Image that will be set on the dialog.
    /// - Returns: Dialog
    @discardableResult func show(alert title: String,
                                        message: String,
                                        image: UIImage?) -> Dialog {
        let dialog = Dialog.alert(title: title, message: message, image: image)
        dialog.show(in: self)
        return dialog
    }
    
    /// A Loading Dialog
    ///
    /// - Parameters:
    ///   - title: The title that will be set on the dialog.
    ///   - message: The message that will be set on the dialog.
    ///   - image: The Image that will be set on the dialog.
    /// - Returns: Dialog
    @discardableResult func show(loading title: String,
                                        message: String,
                                        image: UIImage?) -> Dialog {
        let dialog = Dialog.loading(title: title, message: message, image: image)
        dialog.show(in: self)
        return dialog
    }
}

public extension Dialog {
    
    /// Primary initializer
    ///
    /// - Parameters:
    ///   - title: The title that will be set on the dialog.
    ///   - message: The message that will be set on the dialog.
    ///   - image: The Image that will be set on the dialog.
    /// - Returns: Dialog
    @discardableResult class func alert(title: String,
                            message: String,
                            image: UIImage? =  nil) -> Dialog {
        return Dialog(title: title, message: message, image: image)
    }
    
    /// A Loading Dialog
    ///
    /// - Parameters:
    ///   - title: The title that will be set on the dialog.
    ///   - message: The message that will be set on the dialog.
    ///   - image: The Image that will be set on the dialog.
    /// - Returns: Dialog
    @discardableResult class func loading(title: String,
                              message: String,
                              image: UIImage? =  nil) -> Dialog {
        let dialog = Dialog(title: title, message: message, image: image)
        dialog.dismissWithOutsideTouch = false
        dialog.allowDragGesture = false
        let indicator = UIActivityIndicatorView(style: .gray)
        dialog.loadingIndicator = indicator
        dialog.container.addSubview(dialog.loadingIndicator!)
        dialog.loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
        dialog.loadingIndicator?.centerXAnchor.constraint(equalTo: dialog.container.centerXAnchor).isActive = true
        dialog.loadingIndicator?.centerYAnchor.constraint(equalTo: dialog.container.centerYAnchor).isActive = true
        dialog.customViewSizeRatio = 0.2
        return dialog
    }
}

fileprivate class BaseView: UIView {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
        super.touchesBegan(touches, with: event)
    }
}

