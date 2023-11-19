import consumer from "channels/consumer"

const subscribeToVideo = (videoId, callbacks) => {
  consumer.subscriptions.create({ channel: "VideoChannel", id: videoId }, {
    connected: callbacks.connected,
    disconnected: callbacks.disconnected,
    received: callbacks.received
  });
};

export { subscribeToVideo }

// const subscribeToVideo = (videoId, callbacks) => {
//   consumer.subscriptions.create({ channel: "VideoChannel", id: videoId }, {
//     connected: callbacks.connected,
//     disconnected: callbacks.disconnected,
//     received: callbacks.received
//   });
// };
//
// export { subscribeToVideo };

// consumer.subscriptions.create("VideoChannel", {
//   connected() {
//     // Called when the subscription is ready for use on the server
//     console.log('connected')
//   },
//
//   disconnected() {
//     // Called when the subscription has been terminated by the server
//   },
//
//   received(data) {
//     // Called when there's incoming data on the websocket for this channel
//     console.log("received messages", data)
//   }
// });
