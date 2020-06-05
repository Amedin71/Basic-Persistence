https://drive.google.com/file/d/19d6WdS8bv9YMRZJQbAfILoIL8XRAqOzx/view?usp=sharing

# iOS Guided Project: Basic Persistence

## Create Xcode Project

1. Create Xcode project called "Stars" (single view app template)
2. Demo complete app show off features

## Initial Storyboard Tasks

1. Drag in 2 textfields, 2 buttons, and a tableview
2. Embed textfields in a vertical stackview: fill, fill, and 16 pts of space
3. Embed buttons in a horizontal stackview: fill, fill equally, and 20 pts of space
4. Move horizontal button stackview to be the 3rd member of the vertical stackview
5. Constrain the vertical stackview with: top = 30, leading = 15, trailing = 15
6. Constrain tableview with: top = 8, leading = 0, trailing = 0, bottom = 0
7. Set up a single cell prototype with 2 labels in an over/under design
8. Top label will hold star's name, 17pt system font
9. Bottom label will hold star's distance, 12pt system font
10. Place both labels in a vertical stackview: leading, fill, and 1 pt of spacing
11. Constrain stackview in cell with: center y in container, leading to margin = 0

## Rename `ViewController`

1. Use the refactor tool to rename the `ViewController` class to `StarsViewController`

### Add Outlets to `StarsViewController`

```swift
let starController = StarController()
	    
@IBOutlet var nameTextField: UITextField!
@IBOutlet var distanceTextField: UITextField!
@IBOutlet var tableView: UITableView!
```

### Add Action Stubs

```swift
@IBAction func createStar(_ sender: UIButton) {
}

@IBAction func printStars(_ sender: UIButton) {
}
```

### Wire Up Actions and Outlets

1. Wire up the above outlets and actions to their appropriate controls in the storyboard

### Compile and Run

1. Use thumbs up/yes button in Zoom if it works without crashing, fix any issues if it crashes. (Outlet connections)

## Create Star Model

```swift
import Foundation
	
struct Star: Codable {
    var name: String
    var distance: Double
}
```

## Create StarController

```swift
import Foundation
	
class StarController {

   private(set) var stars: [Star] = []

    @discardableResult func createStar(named name: String, withDistance distance: Double) -> Star {
        let star = Star(name: name, distance: distance)
        stars.append(star)
	return star
    }
}
```

1. Once implemented, discuss the benefits of the `discardableResult` annotation.
2. Also discuss what benefit we get by implementing a model controller rather than placing this code in the view controller

### Add Model Controller to View Controller as Property

```swift
let starController = StarController()
```

## Parse User Input and Create Star

1. Discuss why it's important to validate the data provided by the user before model object creation.

```swift
@IBAction func create(_ sender: Any) {
    guard let name = nameTextField.text,
        let distanceString = distanceTextField.text,
	!name.isEmpty,
	!distanceString.isEmpty,
        let distance = Double(distanceString) else { return }
        
    starController.createStar(withName: name, distance: distance)
    nameTextField.text = ""
    distanceTextField.text = ""
    nameTextField.becomeFirstResponder()
    tableView.reloadData()
}
```

## TableView Setup

1. Set `PlanetCell` as reuse identifier in the storyboard
2. Add protocol conformance to the view controller as shown below:

	```swift
	extension StarsViewController: UITableViewDataSource {
		
	    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return starController.stars.count
	    }
		
	    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlanetCell", for: indexPath) as? StarTableViewCell else { return UITableViewCell() }
			
	        let star = starController.stars[indexPath.row]
	        cell.star = star
			
	        return cell
	    }
	}
	```

### Create `StarTableViewCell`

```swift
class StarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    var star: Star? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let star = star else { return }
        
        nameLabel.text = star.name
        distanceLabel.text = star.distanceDescription
    }
}
```

1. Set the cell class in the custom class field of the cell in the storyboard
2. Wire up outlets to their labels in the cell

### Add `distanceDescription` computed property to Model

```swift
var distanceDescription: String {
    return "\(distance) light years away"
}
```

1. Once implemented, talk about how computed properties work and explain how this logic placed here enables all `Star` objects to describe their distance and why this is an example of the `D-R-Y` Principle.

## List Stars

1. Create function in model controller

	```swift
	func listStars() -> String {
	    var output = ""
	    for star in stars {
	        output += "\(star.name) is \(star.distanceDescription).\n"
	    }
	    return output
	}
	```

### Implement List Stars in Action Handler

1. Implement action in view controller

	```swift
	@IBAction func printStars(_ sender: UIButton) {
	    print(starController.listStars())
	}
	```

### Test User Input

1. Use thumbs up/yes button in Zoom if it works without crashing and shows star objects in the tableview
2. Stars to test with:
	* **Proxima Centauri** (in a triple star system): 4.24 light years
	* **Barnard's Star**: 5.96 light years
	* **Sirius**: 8.58 light years
	* **Procyon**: 11.4 light years
	* **Tau Ceti**: 11.89 light years
	* **VY Canis Majoris** (One of the largest stars): 3,900 light years
	* **Sun**: 0 light years


## Persisting Star Data

1. Discuss current lack of saving data and how it's a pain to enter star info every run
	* Run app
	* Add stars
	* Quit app
	* Run app again
	* Oh no! Nothing saved

### Implement Persistence Methods in Model Controller 

1. Add a `persistentFileURL` variable
	
	```swift
	private var persistentFileURL: URL? {
	    let fileManager = FileManager.default
	    guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
		
	    // /Users/paulsolt/Documents
	    // /Users/paulsolt/Documents/stars.plist

	    return documents.appendingPathComponent("stars.plist")
	}
	```

2. Implement save (saving array of stars)

	```swift
	func saveToPersistentStore() {
	    guard let url = persistentFileURL else { return }
		
	    do {
	        let encoder = PropertyListEncoder()
	        let data = try encoder.encode(stars)
	        try data.write(to: url)
	    } catch {
	        print("Error saving stars data: \(error)")
	    }
	}
	```

4. Implement load - discuss why we're checking if the file exists first (first run? the stars.plist file wouldn't exist)

	```swift
	func loadFromPersistentStore() {
	    let fileManager = FileManager.default
	    guard let url = persistentFileURL, fileManager.fileExists(atPath: url.path) else { return }
		
	    do {
	        let data = try Data(contentsOf: url)
	        let decoder = PropertyListDecoder()
	        stars = try decoder.decode([Star].self, from: data)
        } catch {
	        print("Error loading stars data: \(error)")
	    }
	}
	```

5. QUESTION: Data needs load from the file on app start, where should we put this code?
	* We can create a `init()` method to load the data

6. Create `init` method in Model Controller to load data

	```swift
	init() {
	    loadFromPersistentStore()
	}
	```

7. Add call to save when star objects are created

	```swift
	@discardableResult func createStar(withName name: String, distance: Double) -> Star {
        let star = Star(name: name, distance: distance)
        stars.append(star)
        saveToPersistentStore()
        return star
    }
	```

## Final Testing

1. Run app and add stars, ensure they display in the tableview and use the `print stars` button to print them to the console
2. Stars to test with:
	* **Proxima Centauri** (in a triple star system): 4.24 light years
	* **Barnard's Star**: 5.96 light years
	* **Sirius**: 8.58 light years
	* **Procyon**: 11.4 light years
	* **Tau Ceti**: 11.89 light years
	* **VY Canis Majoris** (One of the largest stars): 3,900 light years
	* **Sun**: 0 light years
3. Quit the app and relaunch to show that star data was saved/reloaded on launch
