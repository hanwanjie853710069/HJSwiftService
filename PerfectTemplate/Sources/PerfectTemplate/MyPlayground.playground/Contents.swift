import UIKit
import Foundation
var str = "Hello, playground"


for i in 0...9 {
    print(i)
}

var tempCode = ""
for _ in 0...7 {
    let arcCode = Int(arc4random() % 10)
    tempCode = tempCode + "\(arcCode)"
}

