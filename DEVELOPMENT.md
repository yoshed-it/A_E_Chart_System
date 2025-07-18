# Development Guide

This document outlines the development standards and tools used in the Pluckr project.

## 📚 Documentation Standards

### Code Documentation

All public APIs in the Pluckr project should be documented using Swift's documentation comments. Follow these guidelines:

#### For Classes and Structs
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
 */
```

#### For Methods
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

#### For Properties
```swift
/// Brief description of what this property represents
/// - Note: Any important notes about usage
/// - Warning: Any warnings about usage
var myProperty: String
```

### Documentation Template

See `Utils/Documentation.swift` for a complete template and examples.

## 🔧 SwiftLint Setup

### Installation

1. **Install SwiftLint:**
   ```bash
   ./Scripts/install_swiftlint.sh
   ```

2. **Manual Installation (if script fails):**
   ```bash
   brew install swiftlint
   ```

### Usage

#### Command Line
```bash
# Run linting
./Scripts/lint.sh

# Auto-fix issues
./Scripts/autocorrect.sh

# Or run directly
swiftlint lint
swiftlint autocorrect
```

#### Xcode Integration

1. **Add Build Phase Script:**
   - Open your Xcode project
   - Select your target
   - Go to "Build Phases"
   - Click "+" and select "New Run Script Phase"
   - Add this script:
   ```bash
   "${SRCROOT}/Scripts/swiftlint_build_phase.sh"
   ```

2. **Configure Xcode:**
   - SwiftLint will now run during builds
   - Issues will appear in the Xcode issue navigator
   - Build will fail if critical issues are found

### Configuration

The SwiftLint configuration is in `.swiftlint.yml`. Key settings:

- **Line Length:** 120 characters (warning), 150 characters (error)
- **Function Body:** 50 lines (warning), 100 lines (error)
- **Type Body:** 300 lines (warning), 500 lines (error)
- **File Length:** 500 lines (warning), 1000 lines (error)

### Custom Rules

The configuration includes a custom rule to ensure public APIs are documented:
- **Rule:** `documented_public_api`
- **Scope:** Public and open declarations
- **Severity:** Warning

## 🎯 Code Style Guidelines

### Naming Conventions

- **Classes/Structs:** PascalCase (e.g., `ClientRepository`)
- **Functions/Methods:** camelCase (e.g., `fetchClients`)
- **Variables/Properties:** camelCase (e.g., `clientName`)
- **Constants:** camelCase (e.g., `maxRetryCount`)
- **Enums:** PascalCase (e.g., `LogLevel`)

### File Organization

```
Pluckr/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── ViewModels/      # MVVM view models
├── Services/        # Business logic services
├── Repositories/    # Data access layer
├── Components/      # Reusable UI components
├── Utils/           # Utility functions and extensions
├── Resources/       # Assets, themes, constants
└── Scripts/         # Build and development scripts
```

### Import Order

1. Apple frameworks (Foundation, SwiftUI, etc.)
2. Third-party frameworks (Firebase, etc.)
3. Local modules

### Error Handling

- Use `Logger` utility for all logging
- Provide meaningful error messages
- Use proper error types when possible
- Handle errors gracefully in UI

### Async/Await

- Prefer async/await over completion handlers
- Use `@MainActor` for UI updates
- Handle errors with try-catch blocks

## 🚀 Development Workflow

### Before Committing

1. **Run SwiftLint:**
   ```bash
   ./Scripts/lint.sh
   ```

2. **Auto-fix issues:**
   ```bash
   ./Scripts/autocorrect.sh
   ```

3. **Check documentation:**
   - Ensure all public APIs are documented
   - Update documentation for changed APIs

4. **Test your changes:**
   - Build the project
   - Run any existing tests
   - Test the affected functionality

### Code Review Checklist

- [ ] Code follows naming conventions
- [ ] Public APIs are documented
- [ ] Error handling is appropriate
- [ ] No force unwrapping (unless necessary)
- [ ] Async/await used where appropriate
- [ ] SwiftLint passes without warnings
- [ ] No debug print statements (use Logger)

## 📋 TODO List

### Development Tasks
- [ ] **Auto-Fill Disabled for Development**: Remove `.textContentType(.none)` and `.autocorrectionDisabled()` from auth forms before production
  - **Files**: `Views/Auth/SignUpView.swift`, `Views/Auth/LoginView.swift`
  - **Search for**: `// MARK: - Development: Disabled Auto-Fill`
  - **Reason**: These modifiers disable iOS auto-fill which improves UX for real users

### UX Improvements (Priority Order)
- [ ] **User Guidance for Missing Org Context**: Implement prompts when orgId is missing
  - **Status**: ✅ Implemented in ProviderHomeView
  - **Next**: Add user-friendly onboarding guidance
- [ ] **Error Handling**: Show actionable error messages throughout the app
  - **Status**: ✅ Basic implementation in ProviderHomeView
  - **Next**: Expand to all views with error states
- [ ] **Onboarding Flow**: Complete invite-only provider sign-up
  - **Status**: ✅ Join/Create org views implemented
  - **Next**: Test full flow and add user guidance
- [ ] **Admin Dashboard**: Role-based visibility and management
  - **Status**: ✅ Basic admin dashboard implemented
  - **Next**: Add provider management and invite code generation
- [ ] **User Prompts**: Help users understand what to do next
  - **Status**: 🔄 In progress
  - **Next**: Add contextual help and onboarding tips

### Database & Architecture
- [ ] **Firestore Security Rules**: Implement org and role-based access control
  - **Status**: ⏳ Not started
  - **Priority**: High for production
- [ ] **Data Migration**: Ensure existing data works with new org structure
  - **Status**: ✅ Basic migration in OrganizationService
  - **Next**: Test with real data
- [ ] **Provider Creation**: Ensure providers are created under organizations
  - **Status**: ✅ Implemented in onboarding flow
  - **Next**: Verify in all sign-up paths

### Testing & Quality
- [ ] **Unit Tests**: Complete test coverage for new features
  - **Status**: 🔄 Partial coverage
  - **Next**: Add tests for admin dashboard and onboarding
- [ ] **Integration Tests**: Test full user flows
  - **Status**: ⏳ Not started
  - **Next**: Test org join/create flows
- [ ] **Error Scenarios**: Test edge cases and error handling
  - **Status**: ⏳ Not started
  - **Next**: Test network failures, invalid invites, etc.

### Production Checklist
- [ ] Remove development auto-fill disabling from auth forms
- [ ] Test auto-fill functionality works for real users
- [ ] Verify password suggestions work correctly
- [ ] Test on real devices (not just simulator)
- [ ] Implement Firestore security rules
- [ ] Test data migration with production data
- [ ] Verify all onboarding flows work correctly
- [ ] Test admin dashboard functionality
- [ ] Ensure error handling is user-friendly
- [ ] Test invite code generation and validation

## 📖 Additional Resources

- [SwiftLint Documentation](https://realm.github.io/SwiftLint/)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Swift Documentation](https://swift.org/documentation/) 