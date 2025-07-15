/**
 # Pluckr Documentation Standards
 
 This file serves as a template for documenting code in the Pluckr project.
 
 ## Documentation Format
 
 ### For Classes and Structs:
 ```swift
 /**
  *Brief description of what this class/struct does*
  
  This class/struct is responsible for *specific responsibilities*.
  
  ## Usage
  ```swift
  let instance = MyClass()
  instance.doSomething()
  ```
  
  ## Properties
  - `propertyName`: Description of what this property does
  
  ## Methods
  - `methodName()`: Description of what this method does
  
  ## Example
  ```swift
  let viewModel = MyViewModel()
  viewModel.loadData()
  ```
  */
 ```
 
 ### For Methods:
 ```swift
 /**
  *Brief description of what this method does*
  
  - Parameter paramName: Description of the parameter
  - Parameter anotherParam: Description of another parameter
  - Returns: Description of what is returned
  - Throws: Description of what errors might be thrown
  
  ## Example
  ```swift
  let result = try await myMethod(param1: "value", param2: 42)
  ```
  */
 ```
 
 ### For Properties:
 ```swift
 /// Brief description of what this property represents
 /// - Note: Any important notes about usage
 /// - Warning: Any warnings about usage
 var myProperty: String
 ```
 
 ### For Protocols:
 ```swift
 /**
  *Brief description of what this protocol defines*
  
  This protocol defines the contract for *specific functionality*.
  
  ## Conforming Types
  - `Type1`: Description of how it conforms
  - `Type2`: Description of how it conforms
  */
 ```
 
 ### For Extensions:
 ```swift
 /**
  *Brief description of what this extension adds*
  
  This extension adds *specific functionality* to *base type*.
  */
 ```
 
 ## Documentation Tags
 
 - `Parameter`: Document method parameters
 - `Returns`: Document return values
 - `Throws`: Document errors that can be thrown
 - `Note`: Add important notes
 - `Warning`: Add warnings
 - `Example`: Provide usage examples
 - `SeeAlso`: Reference related code
 - `Since`: Version when this was added
 - `Deprecated`: Mark deprecated code
 */ 