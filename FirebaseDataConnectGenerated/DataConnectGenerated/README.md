This Swift package contains the generated Swift code for the connector `example`.

You can use this package by adding it as a local Swift package dependency in your project.

# Accessing the connector

Add the necessary imports

```
import FirebaseDataConnect
import DataConnectGenerated

```

The connector can be accessed using the following code:

```
let connector = DataConnect.exampleConnector

```


## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code, which can be called from the `init` function of your SwiftUI app

```
connector.useEmulator()
```

# Queries

## ListMoviesQuery


### Using the Query Reference
```
struct MyView: View {
   var listMoviesQueryRef = DataConnect.exampleConnector.listMoviesQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listMoviesQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listMoviesQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.exampleConnector.listMoviesQuery.execute(...)
```


## ListUsersQuery


### Using the Query Reference
```
struct MyView: View {
   var listUsersQueryRef = DataConnect.exampleConnector.listUsersQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listUsersQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listUsersQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.exampleConnector.listUsersQuery.execute(...)
```


## ListUserReviewsQuery


### Using the Query Reference
```
struct MyView: View {
   var listUserReviewsQueryRef = DataConnect.exampleConnector.listUserReviewsQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listUserReviewsQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listUserReviewsQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.exampleConnector.listUserReviewsQuery.execute(...)
```


## GetMovieByIdQuery
### Variables
#### Required
```swift

let id: UUID = ...
```




### Using the Query Reference
```
struct MyView: View {
   var getMovieByIdQueryRef = DataConnect.exampleConnector.getMovieByIdQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getMovieByIdQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getMovieByIdQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.exampleConnector.getMovieByIdQuery.execute(...)
```


## SearchMovieQuery
### Variables


#### Optional
```swift

let titleInput: String = ...
let genre: String = ...
```



### Using the Query Reference
```
struct MyView: View {
   var searchMovieQueryRef = DataConnect.exampleConnector.searchMovieQuery.ref(...)

  var body: some View {
    VStack {
      if let data = searchMovieQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await searchMovieQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.exampleConnector.searchMovieQuery.execute(...)
```


# Mutations
## CreateMovieMutation

### Variables

#### Required
```swift

let title: String = ...
let genre: String = ...
let imageUrl: String = ...
```
 

### One-shot execute
```
DataConnect.exampleConnector.createMovieMutation.execute(...)
```

## UpsertUserMutation

### Variables

#### Required
```swift

let username: String = ...
```
 

### One-shot execute
```
DataConnect.exampleConnector.upsertUserMutation.execute(...)
```

## AddReviewMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
let rating: Int = ...
let reviewText: String = ...
```
 

### One-shot execute
```
DataConnect.exampleConnector.addReviewMutation.execute(...)
```

## DeleteReviewMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
```
 

### One-shot execute
```
DataConnect.exampleConnector.deleteReviewMutation.execute(...)
```

