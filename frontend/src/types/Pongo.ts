export interface NotifPayload {
  ship: string;
  ship_url: string;
  conversation_id: string;
  message_id?: string;
}

export interface Reactions {
  [emoji: string]: string[];
}

export type MessageStatus = 'pending' | 'sent' | 'delivered' | 'failed'

export type NotifLevel = 'off' | 'low' | 'medium' | 'high'

export interface SetNotifParams {
  shipUrl: string;
  expoToken?: string;
  level: NotifLevel;
}

export interface GetMessagesParams {
  chatId: string;
  msgId: string;
  numBefore: number;
  numAfter: number;
  append?: boolean;
  prepend?: boolean;
}

export interface NotifSettings {
  expo_token: string;
  ship_url: string;
  level: NotifLevel;
}

export interface Message {
  author: string;
  id: string;
  identifier?: string;
  timestamp: number;
  kind: MessageKind;
  content: string;
  reactions: Reactions;
  edited: boolean;
  reference: string | null;
  status?: MessageStatus;
}

export interface Chat {
  conversation: {
    id: string;
    name: string;
    members: string[];
    leaders: string[];
    last_active: number; // hoon timestamp
    last_read: string;
  }
  messages: Message[];
  last_message: Message | null;
  unreads: number;
}

export interface Chats {
  [chatId: string]: Chat
}

export type SearchType = 'ship' | 'nick' | 'chat' | 'message' | 'tag'

export type MessageKind = 'text'
  | 'image'
  | 'link'
  | 'app-link'
  | 'code'
  | 'reply'
  | 'member-add'
  | 'member-remove'
  | 'change-name'
  | 'leader-add'
  | 'leader-remove'
  | 'change-router'

export interface ConversationsUpdate {
  conversations: Chat[]
}

export interface MessageListUpdate {
  message_list: Message[]
}

export interface InviteUpdate {
  invite: {
    conversation: string
  }
}

export interface SendingUpdate {
  sending: {
    conversation_id: string;
    identifier: string;
  }
}

export interface DeliveredUpdate {
  delivered: {
    conversation_id: string;
    message_id: string;
    identifier: string;
  }
}

export interface SearchUpdate {
  search_result: {
    conversation_id: string;
    message: Message;
  }[]
}

export interface MessageUpdate {
  message: {
    conversation_id: string;
    message: Message;
  }
}

export type Update = ConversationsUpdate
  | MessageListUpdate
  | InviteUpdate
  | SendingUpdate
  | DeliveredUpdate
  | SearchUpdate
  | MessageUpdate

export interface SendMessagePayload {
  self: string;
  convo: string;
  kind: MessageKind;
  content: string;
  ref?: string;
  resend?: Message;
  mentions?: string[];
}
