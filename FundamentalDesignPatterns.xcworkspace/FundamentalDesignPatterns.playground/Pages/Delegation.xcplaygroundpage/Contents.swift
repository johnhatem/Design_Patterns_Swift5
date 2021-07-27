/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Delegation
 - - - - - - - - - -
 ![Delegation Diagram](Delegation_Diagram.png)
 
 * An **object needing a delegate**, (aka the **delegating object**). This is the object that *has* a delegate. The delegate is usually held as a weak property to avoid *a retain cycle* where the delegating object retains the delegate, which retains the delegating object.
 * A **delegate protocol**, which defines the methods the delegate may or should implement.
 * A **delegate**, which is the helper object that implements the delegate protocol.
 
 The delegation pattern allows an object to use a helper object to perform a task, instead of doing the task itself.
 
 This allows for code reuse through object composition, instead of inheritance.
 
 By relying on a *delegate protocol* instead of a concrete object, the implementation is much more reliable: *any object that implements the protocol can be used as the delegate!.*
 
 + In Apple frameworks, both `DataSource` and `Delegate` named objects follow the delegation pattern.
    * `DataSourse`: used to group delegate methods that *provide* data. (e.g., `UITableViewDataSource` is expected to provide `UITableViewCell`s to display.
    * `Delegate`: used to group methods that *receive* data or events. (e.g., `UITableViewDelegate` is notified whenever a row is selected).
    * it is common for the `dataSource` and `delegate` to be set to the *same* object such as the view controller that owns a `UITableView`. However, they don't have to be, and it can be very beneficial at times to have them set to different objects.
 
 ## Code Example
 */

import UIKit

public class MenuViewController: UIViewController {
    
    public weak var delegate: MenuViewControllerDelegate?
    
    @IBOutlet public var tableView: UITableView! {
        didSet {  // For using didSet here check: https://cocoacasts.com/tips-and-tricks-using-didset-property-observers-to-configure-outlets
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private let items = ["item1", "item2", "item3"]
}

// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.menuViewController(self, didSelectItemAtIndex: indexPath.row)
    }
}


// Create a delegate to be notified whenever a user selects a menu item
public protocol MenuViewControllerDelegate: AnyObject {
    func menuViewController(_ menuViewController: MenuViewController, didSelectItemAtIndex index: Int)
}


/*:
 
 ## Another Simple Example
 */

// Object Needing a Delegate           <<Protocol>>              Object acting as a delegate
//     |Bakery| --Delegate To----->   |BakeryDelegate|   <-------conforms to---- |CookieShop|
// has property delegate               has functions            implements functions in protocol
// calls delegate.functions


struct Cookie {
    var size: Int = 5
    var hasChocolateChips: Bool = false
}


protocol BakeryDelegate: AnyObject { //class to create a weak property delegate
    func cookieWasBaked(_ cookie: Cookie)
}


class CookieShop: BakeryDelegate {
    func cookieWasBaked(_ cookie: Cookie) {
        print("A new cookie was baked, with size \(cookie.size)")
    }
}


class Bakery {
    
    weak var delegate: BakeryDelegate?
    
    func makeCookie() {
        var cookie = Cookie()
        cookie.size = 6
        cookie.hasChocolateChips = true
        
        delegate?.cookieWasBaked(cookie)
    }
}

let shop = CookieShop()
let bakery = Bakery()
bakery.delegate = shop

bakery.makeCookie()
