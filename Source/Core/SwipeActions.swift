//
//  Swipe.swift
//  Eureka
//
//  Created by Marco Betschart on 14.06.17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import Foundation

public typealias SwipeActionHandler = (ContextualAction, ContextualActionSource, ((Bool) -> Void)?) -> Void

public class SwipeAction{
	public let contextualAction: ContextualAction
	
	@available(iOS 11, *)
	public var backgroundColor: UIColor?{
		get{
			guard let contextualAction = self.contextualAction as? UIContextualAction else{ return nil }
			return contextualAction.backgroundColor
		}
		set{
			guard let contextualAction = self.contextualAction as? UIContextualAction else{ return }
			contextualAction.backgroundColor = newValue
		}
	}
	
	@available(iOS 11, *)
	public var image: UIImage?{
		get{
			guard let contextualAction = self.contextualAction as? UIContextualAction else{ return nil }
			return contextualAction.image
		}
		set{
			guard let contextualAction = self.contextualAction as? UIContextualAction else{ return }
			return contextualAction.image = newValue
		}
	}
	
	public var title: String?{
		get{
			if #available(iOS 11, *), let contextualAction = self.contextualAction as? UIContextualAction{
				return contextualAction.title
			
			} else if let contextualAction = self.contextualAction as? UITableViewRowAction{
				return contextualAction.title
			}
			return nil
		}
		set{
			if #available(iOS 11, *), let contextualAction = self.contextualAction as? UIContextualAction{
				contextualAction.title = newValue
			
			} else if let contextualAction = self.contextualAction as? UITableViewRowAction{
				contextualAction.title = newValue
			}
		}
	}
	
	public let handler: SwipeActionHandler
	public let style: Style
	
	public init(style: Style, title: String?, handler: @escaping SwipeActionHandler){
		self.style = style
		self.handler = handler
		
		if #available(iOS 11, *){
			self.contextualAction = UIContextualAction(style: style.contextualStyle as! UIContextualAction.Style, title: title){ action, view, completion -> Void in
				handler(action, view, completion)
			}
			
		} else {
			self.contextualAction = UITableViewRowAction(style: style.contextualStyle as! UITableViewRowActionStyle,title: title){ (action, indexPath) -> Void in
				handler(action, indexPath, nil)
			}
		}
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
		
		public init(contextualStyle: ContextualStyle){
			if #available(iOS 11, *), let contextualStyle = contextualStyle as? UIContextualAction.Style{
				switch contextualStyle{
				case .normal:
					self = .normal
				case .destructive:
					self = .destructive
				}
				
			} else if let contextualStyle = contextualStyle as? UITableViewRowActionStyle{
				switch contextualStyle{
				case .normal:
					self = .normal
				case .destructive:
					self = .destructive
				case .default:
					fatalError("Unmapped UITableViewRowActionStyle for SwipeActionStyle: \(contextualStyle)")
				}
				
			} else {
				fatalError("Invalid platformValue for SwipeActionStyle: \(contextualStyle)")
			}
		}
	}
}


public class SwipeConfiguration{
	
	public init(configure: (SwipeConfiguration) -> Void){
		configure(self)
	}
	
	public var performsFirstActionWithFullSwipe: Bool = false
	public var actions: [SwipeAction] = []
	
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


public protocol ContextualAction{}
extension UITableViewRowAction: ContextualAction{}

@available(iOSApplicationExtension 11.0, *)
extension UIContextualAction: ContextualAction{}

public protocol ContextualStyle{}
extension UITableViewRowActionStyle: ContextualStyle{}

@available(iOSApplicationExtension 11.0, *)
extension UIContextualAction.Style: ContextualStyle{}

public protocol ContextualActionSource{}
extension IndexPath: ContextualActionSource{}

@available(iOSApplicationExtension 11.0, *)
extension UIView: ContextualActionSource{}
