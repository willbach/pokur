export class Channel {
    onChannelError: (err: any) => void;
    onChannelOpen: (e: any) => void;
    init(): void;
    debounceInterval: number;
    uid: string;
    requestId: number;
    eventSource: EventSource;
    lastEventId: number;
    lastAcknowledgedEventId: any;
    outstandingPokes: Map<any, any>;
    outstandingSubscriptions: Map<any, any>;
    outstandingJSON: any[];
    debounceTimer: NodeJS.Timeout;
    resetDebounceTimer(): void;
    setOnChannelError(onError?: (err: any) => void): void;
    setOnChannelOpen(onOpen?: (e: any) => void): void;
    deleteOnUnload(): void;
    clearQueue(): void;
    poke(ship: any, app: any, mark: any, json: any, successFunc: any, failureFunc: any): void;
    subscribe(ship: any, app: any, path: any, connectionErrFunc?: any, eventFunc?: any, quitFunc?: any, subAckFunc?: any): number;
    delete(): void;
    unsubscribe(subscription: any): void;
    sendJSONToChannel(j: any): void;
    connectIfDisconnected(): void;
    channelURL(): string;
    nextId(): number;
}
