--!optimize 2
--!strict

local Promise = require(script.Parent.Parent.Packages.Promise)

type Promise<T...> = Promise.TypedPromise<T...>
type Signal<Function, Arguments...> = {
	Connect: (self: Signal<Function, Arguments...>, callback: Function) -> RBXScriptConnection,
	Once: (self: Signal<Function, Arguments...>, callback: Function) -> RBXScriptConnection,
	Wait: (self: Signal<Function, Arguments...>) -> Arguments...,
}

-- ProfileService
export type DataStoreHandler = "ForceLoad" | "Steal" | "Repeat" | "Cancel"

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
	ListenToHopReady: (self: ViewProfile<DataType, RobloxMetadata>) -> RBXScriptConnection,

	AddUserId: (self: ViewProfile<DataType, RobloxMetadata>, userId: number) -> (),
	RemoveUserId: (self: ViewProfile<DataType, RobloxMetadata>, userId: number) -> (),
	Identify: (self: ViewProfile<DataType, RobloxMetadata>) -> string,

	Save: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
	SaveAsync: (self: ViewProfile<DataType, RobloxMetadata>) -> Promise.Promise,

	ClearGlobalUpdates: (self: ViewProfile<DataType, RobloxMetadata>) -> (),

	Overwrite: (self: ViewProfile<DataType, RobloxMetadata>) -> (),
	OverwriteAsync: (self: ViewProfile<DataType, RobloxMetadata>) -> Promise.Promise,

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
	Next: (self: ProfileVersionQuery<DataType, RobloxMetadata>) -> ViewProfile<DataType, RobloxMetadata>?,
	NextAsync: (self: ProfileVersionQuery<DataType, RobloxMetadata>) -> Promise<ViewProfile<DataType, RobloxMetadata>?>,
}

export type ProfileStore<DataType, RobloxMetadata = unknown> = {
	Mock: ProfileStore<DataType, RobloxMetadata>,

	LoadProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		notReleasedHandler: DataStoreHandler?
	) -> Profile<DataType, RobloxMetadata>?,
	LoadProfileAsync: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		notReleasedHandler: DataStoreHandler?
	) -> Promise<Profile<DataType, RobloxMetadata>?>,

	GlobalUpdateProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		updateHandler: GlobalUpdateHandler
	) -> GlobalUpdates?,
	GlobalUpdateProfileAsync: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		updateHandler: GlobalUpdateHandler
	) -> Promise<GlobalUpdates?>,

	ViewProfile: (
		self: ProfileStore<DataType, RobloxMetadata>,
		profileKey: string,
		version: string?
	) -> Profile<DataType, RobloxMetadata>?,
	ViewProfileAsync: (
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

	WipeProfile: (self: ProfileStore<DataType, RobloxMetadata>, profileKey: string) -> boolean,
	WipeProfileAsync: (self: ProfileStore<DataType, RobloxMetadata>, profileKey: string) -> Promise<boolean>,
}

export type ProfileService = {
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
