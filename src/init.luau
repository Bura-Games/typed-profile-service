--!optimize 2
--!strict

local Types = require(script.Types)

export type BaseDataStoreHandlers = Types.BaseDataStoreHandlers
export type DataStoreHandlers = Types.DataStoreHandlers
export type NotReleasedHandler = Types.NotReleasedHandler
export type DataStoreHandler = Types.DataStoreHandler

export type GlobalUpdateHandler = Types.GlobalUpdateHandler
export type GlobalUpdateData = Types.GlobalUpdateData

export type GlobalUpdates = Types.GlobalUpdates
export type ProfileMetadata = Types.ProfileMetadata
export type Profile<DataType, RobloxMetadata = unknown> = Types.Profile<DataType, RobloxMetadata>
export type ViewProfile<DataType, RobloxMetadata = unknown> = Types.ViewProfile<DataType, RobloxMetadata>

export type ProfileVersionQuery<DataType, RobloxMetadata = unknown> = Types.ProfileVersionQuery<
	DataType,
	RobloxMetadata
>
export type ProfileStore<DataType, RobloxMetadata = unknown> = Types.ProfileStore<DataType, RobloxMetadata>
export type ProfileService = Types.ProfileService

return require(script.ProfileService) :: ProfileService
