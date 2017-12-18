//
//  Swipe.swift
//  Eureka
//
//  Created by Marco Betschart on 14.06.17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import Foundation

public typealias SwipeActionHandler = (ContextualAction, BaseRow, ((Bool) -> Void)?) -> Void

public class SwipeAction: ContextualAction {
	let handler: SwipeActionHandler
	let style: Style
	
	weak var row: BaseRow!
	
	public var backgroundColor: UIColor?
	public var image: UIImage?
	public var title: String?
	
	public init(style: Style, title: String?, handler: @escaping SwipeActionHandler){
		self.style = style
		self.title = title
		self.handler = handler
	}
	
	var contextualAction: ContextualAction{
		var action: ContextualAction
		
		if #available(iOS 11, *){
			action = UIContextualAction(style: style.contextualStyle as! UIContextualAction.Style, title: title){ [weak self] action, view, completion -> Void in
				guard let strongSelf = self else{ return }
				strongSelf.handler(action, strongSelf.row, completion)
			}
		
		} else {
			action = UITableViewRowAction(style: style.contextualStyle as! UITableViewRowActionStyle,title: title){ [weak self] (action, indexPath) -> Void in
				guard let strongSelf = self else{ return }
				strongSelf.handler(action, strongSelf.row, nil)
			}
		}
		
		action.backgroundColor = self.backgroundColor ?? action.backgroundColor
		action.image = self.image ?? action.image
		
		return action
	}
	
	public enum Style: Int{
		case normal = 0
		case destructive = 1
		
		var contextualStyle: ContextualStyle{
			if #available(iOS 11, *){
				switch self{
				case .normal:
					return UIContextualAction.Style.normal
				case .destructive:
					return UIContextualAction.Style.destructive
				}
				
			} else {
				switch self{
				case .normal:
					return UITableViewRowActionStyle.normal
				case .destructive:
					return UITableViewRowActionStyle.destructive
				}
			}
		}
	}
}

public struct SwipeConfiguration {
	weak var row: BaseRow!
	
	init(_ row: BaseRow){
		self.row = row
	}
	
	public var performsFirstActionWithFullSwipe = false
	public var actions: [SwipeAction] = []{
		willSet{
			for action in newValue{
				action.row = self.row
			}
		}
	}
	
	@available(iOSApplicationExtension 11.0, *)
	public var contextualConfiguration: UISwipeActionsConfiguration?{
		let contextualConfiguration = UISwipeActionsConfiguration(actions: self.contextualActions as! [UIContextualAction])
		contextualConfiguration.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe
		
		return contextualConfiguration
	}
	
	public var contextualActions: [ContextualAction]{
		return self.actions.map{ $0.contextualAction }
	}
}

public protocol ContextualAction {
	var backgroundColor: UIColor?{ get set }
	var image: UIImage?{ get set }
	var title: String?{ get set }
}

extension UITableViewRowAction: ContextualAction {
	public var image: UIImage? {
		get { return nil }
		set { return }
	}
}

@available(iOSApplicationExtension 11.0, *)
extension UIContextualAction: ContextualAction{}

public protocol ContextualStyle{}
extension UITableViewRowActionStyle: ContextualStyle{}

@available(iOSApplicationExtension 11.0, *)
extension UIContextualAction.Style: ContextualStyle{}
