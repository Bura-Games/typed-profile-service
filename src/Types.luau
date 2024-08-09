--!optimize 2
--!strict

local Promise = require(script.Parent.Parent.Promise)

type Promise<T...> = Promise.TypedPromise<T...>
type Signal<Function, Arguments...> = {
	Connect: (self: Signal<Function, Arguments...>, callback: Function) -> RBXScriptConnection,
	Once: (self: Signal<Function, Arguments...>, callback: Function) -> RBXScriptConnection,
	Wait: (self: Signal<Function, Arguments...>) -> Arguments...,
}

-- ProfileService
export type BaseDataStoreHandlers = "ForceLoad" | "Steal"
export type DataStoreHandlers = BaseDataStoreHandlers | "Repeat" | "Cancel"
export type NotReleasedHandler = (placeId: number?, gameJobId: string?) -> DataStoreHandlers
export type DataStoreHandler = BaseDataStoreHandlers | NotReleasedHandler

export type GlobalUpdateHandler = (globalUpdates: GlobalUpdates) -> ()
export type GlobalUpdateData = {
	[string]: unknown,
	Type: string,
}

export type GlobalUpdates = {
	GetActiveUpdates: (self: GlobalUpdates) -> {{number | GlobalUpdateData}},
	GetLockedUpdates: (self: GlobalUpdates) -> {{number | GlobalUpdateData}},

	ListenToNewActiveUpdate: (
		self: GlobalUpdates,
		listener: (updateId: number, updateData: GlobalUpdateData) -> ()
	) -> RBXScriptConnection,
	ListenToNewLockedUpdate: (
		self: GlobalUpdates,
		listener: (updateId: number, updateData: GlobalUpdateData) -> ()
	) -> RBXScriptConnection,

	LockActiveUpdate: (self: GlobalUpdates, updateId: number) -> (),
	ClearLockedUpdate: (self: GlobalUpdates, updateId: number) -> (),

	AddActiveUpdate: (self: GlobalUpdates, updateData: GlobalUpdateData) -> (),
	ChangeActiveUpdate: (self: GlobalUpdates, updateId: number, updateData: GlobalUpdateData) -> (),
	ClearActiveUpdate: (self: GlobalUpdates, updateId: number) -> (),
}

export type ProfileMetadata = {
	ProfileCreateTime: number,
	SessionLoadCount: number,
	ActiveSession: {number | string}?,

	Metatags: {[string]: unknown},
	MetatagsLatest: {[string]: unknown},
}

export type Profile<DataType, RobloxMetadata = unknown> = ViewProfile<DataType, RobloxMetadata> & {
	Data: DataType,
	Metadata: ProfileMetadata,
	MetatagsUpdated: Signal<(metatagsLatest: ProfileMetadata) -> (), ProfileMetadata>,
}

export type ViewProfile<DataType, RobloxMetadata = unknown> = {
	Data: DataType?,
	Metadata: ProfileMetadata?,
	RobloxMetadata: RobloxMetadata,

	UserIds: {number},
	KeyInfo: DataStoreKeyInfo,
	KeyInfoUpdated: Signal<(keyInfo: DataStoreKeyInfo) -> (), DataStoreKeyInfo>,

	GlobalUpdates: GlobalUpdates,

	IsActive: (self: ViewProfile<DataType, RobloxMetadata>) -> boolean,
	GetMetatag: (self: ViewProfile<DataType, RobloxMetadata>, tagName: string) -> unknown,
	SetMetatag: (self: ViewProfile<DataType, RobloxMetadata>, tagName: string, value: unknown) -> (),
	Reconcile: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
	Release: (self: ViewProfile<DataType, RobloxMetadata>) -> (),

	ListenToRelease: (
		self: ViewProfile<DataType, RobloxMetadata>,
		listener: (placeId: number?, jobId: string?) -> ()
	) -> RBXScriptConnection,
	ListenToHopReady: (self: ViewProfile<DataType, RobloxMetadata>, callback: () -> ()) -> RBXScriptConnection,

	AddUserId: (self: ViewProfile<DataType, RobloxMetadata>, userId: number) -> (),
	RemoveUserId: (self: ViewProfile<DataType, RobloxMetadata>, userId: number) -> (),
	Identify: (self: ViewProfile<DataType, RobloxMetadata>) -> string,

	Save: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
	PromiseSave: (self: ViewProfile<DataType, RobloxMetadata>) -> Promise.Promise,

	ClearGlobalUpdates: (self: ViewProfile<DataType, RobloxMetadata>) -> (),

	OverwriteAsync: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
	PromiseOverwrite: (self: ViewProfile<DataType, RobloxMetadata>) -> Promise.Promise,

	StoreOnValueChange: (
		self: ViewProfile<DataType, RobloxMetadata>,
		name: string,
		valueObject: ValueBase
	) -> RBXScriptConnection,
	StoreOnAttributeChange: (
		self: ViewProfile<DataType, RobloxMetadata>,
		name: string,
		object: Instance
	) -> RBXScriptConnection,

	Destroy: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
}

export type ProfileVersionQuery<DataType, RobloxMetadata = unknown> = {
	NextAsync: (self: ProfileVersionQuery<DataType, RobloxMetadata>) -> ViewProfile<DataType, RobloxMetadata>?,
	PromiseNext: (
		self: ProfileVersionQuery<DataType, RobloxMetadata>
	) -> Promise<ViewProfile<DataType, RobloxMetadata>?>,
}

export type ProfileStore<DataType, RobloxMetadata = unknown> = {
	Mock: ProfileStore<DataType, RobloxMetadata>,

	LoadProfileAsync: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		notReleasedHandler: DataStoreHandler?
	) -> Profile<DataType, RobloxMetadata>?,
	PromiseLoadProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		notReleasedHandler: DataStoreHandler?
	) -> Promise<Profile<DataType, RobloxMetadata>?>,

	GlobalUpdateProfileAsync: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		updateHandler: GlobalUpdateHandler
	) -> GlobalUpdates?,
	PromiseGlobalUpdateProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		updateHandler: GlobalUpdateHandler
	) -> Promise<GlobalUpdates?>,

	ViewProfileAsync: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		version: string?
	) -> Profile<DataType, RobloxMetadata>?,
	PromiseViewProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		version: string?
	) -> Promise<Profile<DataType, RobloxMetadata>?>,

	ProfileVersionQuery: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		sortDirection: Enum.SortDirection?,
		minDate: DateTime | nil | number,
		maxDate: DateTime | nil | number
	) -> ProfileVersionQuery<DataType, RobloxMetadata>,

	WipeProfileAsync: (self: ProfileStore<DataType, RobloxMetadata>, profileKey: string) -> boolean,
	PromiseWipeProfile: (self: ProfileStore<DataType, RobloxMetadata>, profileKey: string) -> Promise<boolean>,
}

export type ProfileService = {
	CriticalState: boolean,
	ServiceIssueCount: number,
	ServiceLocked: boolean,

	CorruptionSignal: Signal<(profileStoreName: string, profileKey: string) -> (), string, string>,
	CriticalStateSignal: Signal<(isCriticalState: boolean) -> (), boolean>,
	IssueSignal: Signal<
		(errorMessage: string, profileStoreName: string, profileKey: string) -> (),
		string,
		string,
		string
	>,

	GetProfileStore: <ProfileTemplate, RobloxMetadata>(
		profileStoreIndex: string | {
			Name: string,
			Scope: string?,
		},
		profileTemplate: ProfileTemplate
	) -> ProfileStore<ProfileTemplate, RobloxMetadata>,

	IsLive: () -> boolean,
}

return false
