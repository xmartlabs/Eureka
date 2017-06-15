//
//  Swipe.swift
//  Eureka
//
//  Created by Marco Betschart on 14.06.17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import Foundation

public typealias SwipeActionHandler = (Any, Any, ((Bool) -> Void)?) -> Void


public class SwipeAction{
	
	public let platformValue: Any
	
	public var backgroundColor: UIColor?{
		didSet{
			if #available(iOS 11, *), let platformValue = self.platformValue as? UIContextualAction{
				platformValue.backgroundColor = self.backgroundColor
			}
		}
	}
	
	public var image: UIImage?{
		didSet{
			if #available(iOS 11, *), let platformValue = self.platformValue as? UIContextualAction{
				platformValue.image = self.image
			}
		}
	}
	
	public var title: String?{
		didSet{
			if #available(iOS 11, *), let platformValue = self.platformValue as? UIContextualAction{
				platformValue.title = self.title
			}
		}
	}
	
	public let handler: SwipeActionHandler
	public let style: Style
	
	public init(style: Style, title: String?, handler: @escaping SwipeActionHandler){
		self.style = style
		self.handler = handler
		self.title = title
		
		if #available(iOS 11, *){
			self.platformValue = UIContextualAction(style: style.platformValue as! UIContextualAction.Style, title: title){ action, view, completion -> Void in
				handler(action,view,completion)
			}
			
		} else {
			self.platformValue = UITableViewRowAction(style: style.platformValue as! UITableViewRowActionStyle,title: title){ (action, indexPath) -> Void in
				handler(action,indexPath,nil)
			}
		}
	}
	
	public enum Style: Int{
		case normal = 0
		case destructive = 1
		
		var platformValue: Any{
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
		
		public init(platformValue: Any){
			if #available(iOS 11, *), let platformValue = platformValue as? UIContextualAction.Style{
				switch platformValue{
				case .normal:
					self = .normal
				case .destructive:
					self = .destructive
				}
				
			} else if let platformValue = platformValue as? UITableViewRowActionStyle{
				switch platformValue{
				case .normal:
					self = .normal
				case .destructive:
					self = .destructive
				case .default:
					fatalError("Unmapped UITableViewRowActionStyle for SwipeActionStyle: \(platformValue)")
				}
				
			} else {
				fatalError("Invalid platformValue for SwipeActionStyle: \(platformValue)")
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
	
	public var platformValue: Any?{
		guard #available(iOS 11, *) else{
			return nil
		}
		let platformValue = UISwipeActionsConfiguration(actions: self.platformActions as! [UIContextualAction])
		platformValue.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe
		
		return platformValue
	}
	
	public var platformActions: [Any]{
		return self.actions.map{ $0.platformValue }
	}
}
