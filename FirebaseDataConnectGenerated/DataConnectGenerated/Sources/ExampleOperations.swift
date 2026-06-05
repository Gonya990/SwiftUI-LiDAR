import Foundation

import FirebaseCore
import FirebaseDataConnect




















// MARK: Common Enums

public enum OrderDirection: String, Codable, Sendable {
  case ASC = "ASC"
  case DESC = "DESC"
  }

public enum SearchQueryFormat: String, Codable, Sendable {
  case QUERY = "QUERY"
  case PLAIN = "PLAIN"
  case PHRASE = "PHRASE"
  case ADVANCED = "ADVANCED"
  }


// MARK: Connector Enums

// End enum definitions









public class ListMoviesQuery{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "ListMovies"

  public typealias Ref = QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable, Sendable {




public struct Movie: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
imageUrl: String



public var 
genre: String?


  
  public var movieKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: Movie, rhs: Movie) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
    case imageUrl
    
    case genre
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }

  public func ref(
        
        ) -> QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>  {
        var variables = ListMoviesQuery.Variables()
        

        let ref = dataConnect.query(name: "ListMovies", variables: variables, resultsDataType:ListMoviesQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>
   }

  @MainActor
   public func execute( fetchPolicy: QueryFetchPolicy = .preferCache,  
        
        ) async throws -> OperationResult<ListMoviesQuery.Data> {
        var variables = ListMoviesQuery.Variables()
        

        let ref = dataConnect.query(name: "ListMovies", variables: variables, resultsDataType:ListMoviesQuery.Data.self, publisher: .observableMacro)
        
        let refCast = ref as! QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>
        return try await refCast.execute(fetchPolicy: fetchPolicy)
        
   }
}






public class ListUsersQuery{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "ListUsers"

  public typealias Ref = QueryRefObservation<ListUsersQuery.Data,ListUsersQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable, Sendable {




public struct User: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: String



public var 
username: String


  
  public var userKey: UserKey {
    return UserKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: User, rhs: User) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case username
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
  }
}
public var 
users: [User]

  }

  public func ref(
        
        ) -> QueryRefObservation<ListUsersQuery.Data,ListUsersQuery.Variables>  {
        var variables = ListUsersQuery.Variables()
        

        let ref = dataConnect.query(name: "ListUsers", variables: variables, resultsDataType:ListUsersQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListUsersQuery.Data,ListUsersQuery.Variables>
   }

  @MainActor
   public func execute( fetchPolicy: QueryFetchPolicy = .preferCache,  
        
        ) async throws -> OperationResult<ListUsersQuery.Data> {
        var variables = ListUsersQuery.Variables()
        

        let ref = dataConnect.query(name: "ListUsers", variables: variables, resultsDataType:ListUsersQuery.Data.self, publisher: .observableMacro)
        
        let refCast = ref as! QueryRefObservation<ListUsersQuery.Data,ListUsersQuery.Variables>
        return try await refCast.execute(fetchPolicy: fetchPolicy)
        
   }
}






public class ListUserReviewsQuery{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "ListUserReviews"

  public typealias Ref = QueryRefObservation<ListUserReviewsQuery.Data,ListUserReviewsQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable, Sendable {




public struct User: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: String



public var 
username: String





public struct ReviewReviews: Decodable, Sendable  {
  


public var 
rating: Int?



public var 
reviewDate: LocalDate



public var 
reviewText: String?





public struct Movie: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String


  
  public var movieKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: Movie, rhs: Movie) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
  }
}
public var 
movie: Movie


  

  
  enum CodingKeys: String, CodingKey {
    
    case rating
    
    case reviewDate
    
    case reviewText
    
    case movie
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)
    
    
    
    self.reviewDate = try codecHelper.decode(LocalDate.self, forKey: .reviewDate, container: &container)
    
    
    
    self.reviewText = try codecHelper.decode(String?.self, forKey: .reviewText, container: &container)
    
    
    
    self.movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
    
    
  }
}
public var 
reviews: [ReviewReviews]


  
  public var userKey: UserKey {
    return UserKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: User, rhs: User) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case username
    
    case reviews
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
    self.reviews = try codecHelper.decode([ReviewReviews].self, forKey: .reviews, container: &container)
    
    
  }
}
public var 
user: User?

  }

  public func ref(
        
        ) -> QueryRefObservation<ListUserReviewsQuery.Data,ListUserReviewsQuery.Variables>  {
        var variables = ListUserReviewsQuery.Variables()
        

        let ref = dataConnect.query(name: "ListUserReviews", variables: variables, resultsDataType:ListUserReviewsQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListUserReviewsQuery.Data,ListUserReviewsQuery.Variables>
   }

  @MainActor
   public func execute( fetchPolicy: QueryFetchPolicy = .preferCache,  
        
        ) async throws -> OperationResult<ListUserReviewsQuery.Data> {
        var variables = ListUserReviewsQuery.Variables()
        

        let ref = dataConnect.query(name: "ListUserReviews", variables: variables, resultsDataType:ListUserReviewsQuery.Data.self, publisher: .observableMacro)
        
        let refCast = ref as! QueryRefObservation<ListUserReviewsQuery.Data,ListUserReviewsQuery.Variables>
        return try await refCast.execute(fetchPolicy: fetchPolicy)
        
   }
}






public class GetMovieByIdQuery{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetMovieById"

  public typealias Ref = QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var
id: UUID


    
    
    
    public init (
        
id: UUID

        
        ) {
        self.id = id
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.id == rhs.id
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}

    enum CodingKeys: String, CodingKey {
      
      case id
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }

  }

  public struct Data: Decodable, Sendable {




public struct Movie: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
imageUrl: String



public var 
genre: String?





public struct MovieMetadataMetadata: Decodable, Sendable  {
  


public var 
rating: Double?



public var 
releaseYear: Int?



public var 
description: String?


  

  
  enum CodingKeys: String, CodingKey {
    
    case rating
    
    case releaseYear
    
    case description
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
  }
}
public var 
metadata: MovieMetadataMetadata?





public struct ReviewReviews: Decodable, Sendable  {
  


public var 
reviewText: String?



public var 
reviewDate: LocalDate



public var 
rating: Int?





public struct User: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: String



public var 
username: String


  
  public var userKey: UserKey {
    return UserKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: User, rhs: User) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case username
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
  }
}
public var 
user: User


  

  
  enum CodingKeys: String, CodingKey {
    
    case reviewText
    
    case reviewDate
    
    case rating
    
    case user
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.reviewText = try codecHelper.decode(String?.self, forKey: .reviewText, container: &container)
    
    
    
    self.reviewDate = try codecHelper.decode(LocalDate.self, forKey: .reviewDate, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)
    
    
    
    self.user = try codecHelper.decode(User.self, forKey: .user, container: &container)
    
    
  }
}
public var 
reviews: [ReviewReviews]


  
  public var movieKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: Movie, rhs: Movie) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
    case imageUrl
    
    case genre
    
    case metadata
    
    case reviews
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.metadata = try codecHelper.decode(MovieMetadataMetadata?.self, forKey: .metadata, container: &container)
    
    
    self.reviews = try codecHelper.decode([ReviewReviews].self, forKey: .reviews, container: &container)
    
    
  }
}
public var 
movie: Movie?

  }

  public func ref(
        
id: UUID

        ) -> QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>  {
        var variables = GetMovieByIdQuery.Variables(id:id)
        

        let ref = dataConnect.query(name: "GetMovieById", variables: variables, resultsDataType:GetMovieByIdQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>
   }

  @MainActor
   public func execute( fetchPolicy: QueryFetchPolicy = .preferCache,  
        
id: UUID

        ) async throws -> OperationResult<GetMovieByIdQuery.Data> {
        var variables = GetMovieByIdQuery.Variables(id:id)
        

        let ref = dataConnect.query(name: "GetMovieById", variables: variables, resultsDataType:GetMovieByIdQuery.Data.self, publisher: .observableMacro)
        
        let refCast = ref as! QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>
        return try await refCast.execute(fetchPolicy: fetchPolicy)
        
   }
}






public class SearchMovieQuery{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "SearchMovie"

  public typealias Ref = QueryRefObservation<SearchMovieQuery.Data,SearchMovieQuery.Variables>

  public struct Variables: OperationVariable {
  
        @OptionalVariable
        public var
titleInput: String?

  
        @OptionalVariable
        public var
genre: String?


    
    
    
    public init (
        
        
        
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.titleInput == rhs.titleInput && 
              lhs.genre == rhs.genre
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(titleInput)
  
  hasher.combine(genre)
  
}

    enum CodingKeys: String, CodingKey {
      
      case titleInput
      
      case genre
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      if $titleInput.isSet { 
      try codecHelper.encode(titleInput, forKey: .titleInput, container: &container)
      }
      
      if $genre.isSet { 
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      }
      
    }

  }

  public struct Data: Decodable, Sendable {




public struct Movie: Decodable, Sendable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
genre: String?



public var 
imageUrl: String


  
  public var movieKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: Movie, rhs: Movie) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
    case genre
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }

  public func ref(
        
        
        
        _ optionalVars: ((inout SearchMovieQuery.Variables)->())? = nil
        ) -> QueryRefObservation<SearchMovieQuery.Data,SearchMovieQuery.Variables>  {
        var variables = SearchMovieQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        

        let ref = dataConnect.query(name: "SearchMovie", variables: variables, resultsDataType:SearchMovieQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<SearchMovieQuery.Data,SearchMovieQuery.Variables>
   }

  @MainActor
   public func execute( fetchPolicy: QueryFetchPolicy = .preferCache,  
        
        
        
        _ optionalVars: (@MainActor (inout SearchMovieQuery.Variables)->())? = nil
        ) async throws -> OperationResult<SearchMovieQuery.Data> {
        var variables = SearchMovieQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        

        let ref = dataConnect.query(name: "SearchMovie", variables: variables, resultsDataType:SearchMovieQuery.Data.self, publisher: .observableMacro)
        
        let refCast = ref as! QueryRefObservation<SearchMovieQuery.Data,SearchMovieQuery.Variables>
        return try await refCast.execute(fetchPolicy: fetchPolicy)
        
   }
}






public class CreateMovieMutation{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "CreateMovie"

  public typealias Ref = MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var
title: String

  
        
        public var
genre: String

  
        
        public var
imageUrl: String


    
    
    
    public init (
        
title: String
,
        
genre: String
,
        
imageUrl: String

        
        ) {
        self.title = title
        self.genre = genre
        self.imageUrl = imageUrl
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.title == rhs.title && 
              lhs.genre == rhs.genre && 
              lhs.imageUrl == rhs.imageUrl
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(title)
  
  hasher.combine(genre)
  
  hasher.combine(imageUrl)
  
}

    enum CodingKeys: String, CodingKey {
      
      case title
      
      case genre
      
      case imageUrl
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(title, forKey: .title, container: &container)
      
      
      
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      
      
      
      try codecHelper.encode(imageUrl, forKey: .imageUrl, container: &container)
      
      
    }

  }

  public struct Data: Decodable, Sendable {



public var 
movie_insert: MovieKey

  }

  public func ref(
        
title: String
,
genre: String
,
imageUrl: String

        ) -> MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>  {
        var variables = CreateMovieMutation.Variables(title:title,genre:genre,imageUrl:imageUrl)
        

        let ref = dataConnect.mutation(name: "CreateMovie", variables: variables, resultsDataType:CreateMovieMutation.Data.self)
        return ref as MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>
   }

  @MainActor
   public func execute( 
        
title: String
,
genre: String
,
imageUrl: String

        ) async throws -> OperationResult<CreateMovieMutation.Data> {
        var variables = CreateMovieMutation.Variables(title:title,genre:genre,imageUrl:imageUrl)
        

        let ref = dataConnect.mutation(name: "CreateMovie", variables: variables, resultsDataType:CreateMovieMutation.Data.self)
        
        return try await ref.execute()
        
   }
}






public class UpsertUserMutation{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "UpsertUser"

  public typealias Ref = MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var
username: String


    
    
    
    public init (
        
username: String

        
        ) {
        self.username = username
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.username == rhs.username
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(username)
  
}

    enum CodingKeys: String, CodingKey {
      
      case username
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(username, forKey: .username, container: &container)
      
      
    }

  }

  public struct Data: Decodable, Sendable {



public var 
user_upsert: UserKey

  }

  public func ref(
        
username: String

        ) -> MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>  {
        var variables = UpsertUserMutation.Variables(username:username)
        

        let ref = dataConnect.mutation(name: "UpsertUser", variables: variables, resultsDataType:UpsertUserMutation.Data.self)
        return ref as MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>
   }

  @MainActor
   public func execute( 
        
username: String

        ) async throws -> OperationResult<UpsertUserMutation.Data> {
        var variables = UpsertUserMutation.Variables(username:username)
        

        let ref = dataConnect.mutation(name: "UpsertUser", variables: variables, resultsDataType:UpsertUserMutation.Data.self)
        
        return try await ref.execute()
        
   }
}






public class AddReviewMutation{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "AddReview"

  public typealias Ref = MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var
movieId: UUID

  
        
        public var
rating: Int

  
        
        public var
reviewText: String


    
    
    
    public init (
        
movieId: UUID
,
        
rating: Int
,
        
reviewText: String

        
        ) {
        self.movieId = movieId
        self.rating = rating
        self.reviewText = reviewText
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.movieId == rhs.movieId && 
              lhs.rating == rhs.rating && 
              lhs.reviewText == rhs.reviewText
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(movieId)
  
  hasher.combine(rating)
  
  hasher.combine(reviewText)
  
}

    enum CodingKeys: String, CodingKey {
      
      case movieId
      
      case rating
      
      case reviewText
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
      
      try codecHelper.encode(rating, forKey: .rating, container: &container)
      
      
      
      try codecHelper.encode(reviewText, forKey: .reviewText, container: &container)
      
      
    }

  }

  public struct Data: Decodable, Sendable {



public var 
review_upsert: ReviewKey

  }

  public func ref(
        
movieId: UUID
,
rating: Int
,
reviewText: String

        ) -> MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>  {
        var variables = AddReviewMutation.Variables(movieId:movieId,rating:rating,reviewText:reviewText)
        

        let ref = dataConnect.mutation(name: "AddReview", variables: variables, resultsDataType:AddReviewMutation.Data.self)
        return ref as MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>
   }

  @MainActor
   public func execute( 
        
movieId: UUID
,
rating: Int
,
reviewText: String

        ) async throws -> OperationResult<AddReviewMutation.Data> {
        var variables = AddReviewMutation.Variables(movieId:movieId,rating:rating,reviewText:reviewText)
        

        let ref = dataConnect.mutation(name: "AddReview", variables: variables, resultsDataType:AddReviewMutation.Data.self)
        
        return try await ref.execute()
        
   }
}






public class DeleteReviewMutation{

  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "DeleteReview"

  public typealias Ref = MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var
movieId: UUID


    
    
    
    public init (
        
movieId: UUID

        
        ) {
        self.movieId = movieId
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.movieId == rhs.movieId
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(movieId)
  
}

    enum CodingKeys: String, CodingKey {
      
      case movieId
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
    }

  }

  public struct Data: Decodable, Sendable {



public var 
review_delete: ReviewKey?

  }

  public func ref(
        
movieId: UUID

        ) -> MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>  {
        var variables = DeleteReviewMutation.Variables(movieId:movieId)
        

        let ref = dataConnect.mutation(name: "DeleteReview", variables: variables, resultsDataType:DeleteReviewMutation.Data.self)
        return ref as MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>
   }

  @MainActor
   public func execute( 
        
movieId: UUID

        ) async throws -> OperationResult<DeleteReviewMutation.Data> {
        var variables = DeleteReviewMutation.Variables(movieId:movieId)
        

        let ref = dataConnect.mutation(name: "DeleteReview", variables: variables, resultsDataType:DeleteReviewMutation.Data.self)
        
        return try await ref.execute()
        
   }
}


