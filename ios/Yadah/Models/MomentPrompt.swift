import Foundation

nonisolated struct MomentPrompt: Identifiable, Sendable, Hashable {
    let id: Int
    let body: String
}

extension MomentPrompt {
    static func forToday(date: Date = Date()) -> MomentPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % library.count
        return library[index]
    }

    static let library: [MomentPrompt] = [
        MomentPrompt(
            id: 1,
            body: """
            Whatever is happening right now, God sees you. He knows you and loves you.
            Pause. Take a breath. You are not alone.
            """
        ),
        MomentPrompt(
            id: 2,
            body: """
            You don't have to solve everything today. God knows your needs, and He cares for you.
            Pause. Breathe. Place this moment in His hands.
            """
        ),
        MomentPrompt(
            id: 3,
            body: """
            No matter how today has unfolded, God's love for you has not changed. You are known, loved, and held.
            Take a moment. Breathe.
            """
        ),
        MomentPrompt(
            id: 4,
            body: """
            Remember the time God carried you through. That same God is with you now. His faithfulness has not changed.
            Pause. Take a breath.
            """
        ),
        MomentPrompt(
            id: 5,
            body: """
            Whatever you are carrying today, you can bring it to God. He welcomes you and hears your prayers.
            Take this moment. Breathe.
            """
        ),
        MomentPrompt(
            id: 6,
            body: """
            You may not see the way forward, but God sees you. He can guide your next step.
            Pause. Breathe. Trust His loving care.
            """
        ),
        MomentPrompt(
            id: 7,
            body: """
            Before you head into your next thing, notice the gift God has given you today. Let it remind you of His goodness.
            Breathe.
            """
        ),
        MomentPrompt(
            id: 8,
            body: """
            God knows the needs you haven't spoken aloud. He cares about every part of your life.
            Pause. Breathe. Trust Him for help for today.
            """
        ),
        MomentPrompt(
            id: 9,
            body: """
            Life may feel uncertain right now, but God is still on His throne. You are in His care.
            Relax. Lower your shoulders. Breathe.
            """
        ),
        MomentPrompt(
            id: 10,
            body: """
            Even in this difficult moment, God is near. He knows your pain and will not abandon you.
            Pause. Breathe. Be reminded of His love.
            """
        ),
        MomentPrompt(
            id: 11,
            body: """
            No matter what is happening today or right now in this moment.
            Remind yourself that you woke up today!
            Take a moment. Breathe.
            """
        ),
        MomentPrompt(
            id: 12,
            body: """
            Did something good happen today? Take time to enjoy it with God. He welcomes your joy.
            Pause. Breathe. Celebrate this gift with gratitude.
            """
        ),
        MomentPrompt(
            id: 13,
            body: """
            Has a prayer been answered? Before moving to the next concern, remember what you asked God for.
            Pause. Notice His faithfulness. Celebrate this.
            """
        ),
        MomentPrompt(
            id: 14,
            body: """
            You don't need an occasion to rejoice in God today. A small delight can become a moment of worship.
            Pause. Smile. Breathe.
            """
        ),
        MomentPrompt(
            id: 15,
            body: """
            Notice something ordinary you enjoyed today. A meal. A warm bed. A familiar voice. God's gifts can be easy to overlook.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 16,
            body: """
            Your next breath is a gift. Before you move on, notice the life God has given you today.
            Be present. Breathe.
            """
        ),
        MomentPrompt(
            id: 17,
            body: """
            God reaches you through kindness. Remember that time someone helped you.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 18,
            body: """
            Still waiting for an answer today? You can bring God your questions and thank Him for His goodness.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 19,
            body: """
            You don't know how things will unfold today. But God does, and He welcomes your prayers.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 20,
            body: """
            If today holds sadness, you don't have to hide it from God. He welcomes your tears.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 21,
            body: """
            You will miss all the shots you don't take today. Give God your fears. One day at a time.
            Breathe.
            """
        ),
        MomentPrompt(
            id: 22,
            body: """
            Made a mistake today? Turn toward God. His mercy invites you to return, receive forgiveness, and begin again.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 23,
            body: """
            You don't have to earn God's love by getting everything right today.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 24,
            body: """
            You are allowed to rest. God's care does not depend on your effort today.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 25,
            body: """
            Worn out today? Bring God the strength you have left. Ask Him for help with your next step.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 26,
            body: """
            Someone else's life is not the measure of yours. Ask God to help you notice His gifts today.
            Breathe.
            """
        ),
        MomentPrompt(
            id: 27,
            body: """
            What is good in your life today? Let God draw your attention to something you have overlooked.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 28,
            body: """
            Think of someone whose presence has blessed your life. Remember a laugh, a conversation, or a helping hand.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 29,
            body: """
            Feeling disconnected today? God knows your desire for friendship and fellowship.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 30,
            body: """
            What has God given you to freely share today? Time. A kind word. Practical help.
            Pause. Breathe.
            """
        ),
        MomentPrompt(
            id: 31,
            body: """
            Someone nearby may need encouragement today. Ask God to bring them to mind.
            Pause. Breathe.
            """
        ),
    ]
}
