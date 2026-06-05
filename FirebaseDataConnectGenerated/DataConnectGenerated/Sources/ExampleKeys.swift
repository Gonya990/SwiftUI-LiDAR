import Foundation

import FirebaseCore
import FirebaseDataConnect




public struct MovieMetadataKey {
  
  public private(set) var id: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension MovieMetadataKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension MovieMetadataKey : Equatable {
  public static func == (lhs: MovieMetadataKey, rhs: MovieMetadataKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension MovieMetadataKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension MovieMetadataKey : Sendable {}



public struct MovieKey {
  
  public private(set) var id: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension MovieKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension MovieKey : Equatable {
  public static func == (lhs: MovieKey, rhs: MovieKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension MovieKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension MovieKey : Sendable {}



public struct ReviewKey {
  
  public private(set) var userId: String
  
  public private(set) var movieId: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  userId
    
    case  movieId
    
  }
}

extension ReviewKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.userId = try codecHelper.decode(String.self, forKey: .userId, container: &container)
    
    self.movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(userId, forKey: .userId, container: &container)
      
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
    }
}

extension ReviewKey : Equatable {
  public static func == (lhs: ReviewKey, rhs: ReviewKey) -> Bool {
    
    if lhs.userId != rhs.userId {
      return false
    }
    
    if lhs.movieId != rhs.movieId {
      return false
    }
    
    return true
  }
}

extension ReviewKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.userId)
    
    hasher.combine(self.movieId)
    
  }
}

extension ReviewKey : Sendable {}



public struct UserKey {
  
  public private(set) var id: String
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension UserKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension UserKey : Equatable {
  public static func == (lhs: UserKey, rhs: UserKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension UserKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension UserKey : Sendable {}


