const admin = require('firebase-admin');
const serviceAccount = require('../firebase-service-account.json');

if (process.argv.length !== 3) {
  console.error('Usage: node scripts/test_push.js <device_token>');
  process.exit(1);
}

const token = process.argv[2];

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const message = {
  token,
  notification: {
    title: 'Test Critical Alert',
    body: 'This is a test critical alert from the water monitoring system.',
  },
  android: {
    collapseKey: 'test_node',
    priority: 'high',
    notification: {
      channelId: 'critical_alerts',
      tag: 'test_node',
      sound: 'default',
    },
  },
  apns: {
    headers: {
      'apns-collapse-id': 'test_node',
    },
    payload: {
      aps: {
        category: 'critical_alerts',
        sound: 'default',
        contentAvailable: true,
      },
    },
  },
  data: {
    nodeId: 'ESP32_221A74',
    parameter: 'ph',
    value: '5.8',
    alertType: 'critical',
  },
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Test push sent successfully:', response);
    process.exit(0);
  })
  .catch((error) => {
    console.error('Test push failed:', error);
    process.exit(1);
  });
