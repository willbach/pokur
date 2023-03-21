import { Chat } from "../types/Pongo"

export const DM_DIVIDER = ' & '

export const deSig = (patp: string) => patp.replace(/^~/, '');

export const addSig = (s: string) => s.length === 0 ? '' : `~${deSig(s)}`

export const checkIsDm = (chat: Chat) => {
  if (!chat) {
    return false
  }
  const { conversation: { members, name } } = chat
  return name.split(DM_DIVIDER).length === 2 && members.reduce((acc, mem) => acc && name.split(DM_DIVIDER).includes(addSig(mem)), true)
}

export const getChatName = (self: string, chat?: Chat) => {
  if (!chat) {
    return 'Unknown'
  }
  if (checkIsDm(chat)) {
    return addSig(chat.conversation.members.find(m => m !== deSig(self)) || chat.conversation.name)
  }

  return chat.conversation.name
}
