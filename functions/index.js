'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Sends a notification to the recipient when a message is sent to.
 */
exports.sendNewMessageNotification = functions.firestore.document('/messages/{chatId}/{chat_id}/{timestamp}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    // Get the list of device notification tokens.
    const getRecipientPromise = admin.firestore().collection('users').doc(message.to).get();

    // The snapshot to the user's tokens.
    let recipient;

    // The array containing all the user's tokens.
    let tokens;

    const results = await Promise.all([getRecipientPromise]);

    recipient = results[0];


    tokens = recipient.data().notificationTokens || [];

    // Check if there are any device tokens.
    if (tokens.length === 0) {
      return console.log('There are no notification tokens to send to.');
    }

    // Notification details.
    const payload = {
      notification: {
        title: 'You have new message(s).',
        body: 'Tap to view the message(s).',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error('Failure sending notification to', tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered') {
          tokensToRemove.push(tokens[index]);
        }
      }
    });
    return recipient.ref.update({
      notificationTokens: tokens.filter((token) => !tokensToRemove.includes(token))
    });
  });
