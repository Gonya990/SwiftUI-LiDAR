
import Foundation

import FirebaseCore
import FirebaseDataConnect
public extension DataConnect {

  static let exampleConnector: ExampleConnector = {
    let cacheSettings = CacheSettings(storage: .persistent, maxAge: 0)
    let settings = DataConnectSettings(cacheSettings: cacheSettings)

    let dc = DataConnect.dataConnect(connectorConfig: ExampleConnector.connectorConfig, settings: settings, callerSDKType: .generated)
    return ExampleConnector(dataConnect: dc)
  }()

}

public class ExampleConnector {

  let dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(serviceId: "igorgoncharenko", location: "us-east4", connector: "example")

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations 
    self.listMoviesQuery = ListMoviesQuery(dataConnect: dataConnect)
    self.listUsersQuery = ListUsersQuery(dataConnect: dataConnect)
    self.listUserReviewsQuery = ListUserReviewsQuery(dataConnect: dataConnect)
    self.getMovieByIdQuery = GetMovieByIdQuery(dataConnect: dataConnect)
    self.searchMovieQuery = SearchMovieQuery(dataConnect: dataConnect)
    self.createMovieMutation = CreateMovieMutation(dataConnect: dataConnect)
    self.upsertUserMutation = UpsertUserMutation(dataConnect: dataConnect)
    self.addReviewMutation = AddReviewMutation(dataConnect: dataConnect)
    self.deleteReviewMutation = DeleteReviewMutation(dataConnect: dataConnect)
    
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host, port: Int = DataConnect.EmulatorDefaults.port) {
    self.dataConnect.useEmulator(host: host, port: port)
  }

  // MARK: Operations
public let listMoviesQuery: ListMoviesQuery
public let listUsersQuery: ListUsersQuery
public let listUserReviewsQuery: ListUserReviewsQuery
public let getMovieByIdQuery: GetMovieByIdQuery
public let searchMovieQuery: SearchMovieQuery
public let createMovieMutation: CreateMovieMutation
public let upsertUserMutation: UpsertUserMutation
public let addReviewMutation: AddReviewMutation
public let deleteReviewMutation: DeleteReviewMutation


}
