const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();

const firestore = admin.firestore();
const ADMIN_ROLES = [
  'Admin', 'Chairman', 'Secretary', 'Treasurer', 'Auditor',
  'Kagawad', 'SK Chairman', 'Tanod', 'BHW', 'Admin Staff',
];

function text(value, fallback = '') {
  return value == null ? fallback : String(value);
}

async function writeNotifications(users, notification) {
  for (let offset = 0; offset < users.length; offset += 500) {
    const batch = firestore.batch();
    users.slice(offset, offset + 500).forEach((user) => {
      const ref = user.ref.collection('notifications').doc(notification.id);
      batch.set(ref, {
        type: notification.type,
        referenceId: notification.referenceId,
        title: notification.title,
        body: notification.body,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      batch.set(user.ref, {
        notification: {
          type: notification.type,
          referenceId: notification.referenceId,
          title: notification.title,
          body: notification.body,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        hasUnreadNotifications: true,
      }, { merge: true });
    });
    await batch.commit();
  }
}

async function usersWithRoles(roles) {
  const snapshots = await Promise.all(
    roles.map((role) => firestore.collection('users').where('role', '==', role).get()),
  );
  const users = new Map();
  snapshots.flatMap((snapshot) => snapshot.docs).forEach((user) => users.set(user.id, user));
  return [...users.values()];
}

async function notifyUsers(users, notification) {
  if (users.length === 0) return;
  await writeNotifications(users, notification);
}

exports.notifyResidentsOfAnnouncement = onDocumentCreated(
  { document: 'announcements/{announcementId}' },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const announcement = snapshot.data();
    if (text(announcement.status, 'published').toLowerCase() !== 'published') return;

    const users = await usersWithRoles(['Resident']);
    const notification = {
      id: `announcement_${event.params.announcementId}`,
      type: 'announcement',
      referenceId: event.params.announcementId,
      title: text(announcement.title, 'New barangay announcement'),
      body: text(announcement.body || announcement.description),
    };
    await notifyUsers(users, notification);
  },
);

exports.notifyResidentsWhenAnnouncementPublished = onDocumentUpdated(
  { document: 'announcements/{announcementId}' },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const wasPublished = text(before.status).toLowerCase() === 'published';
    const isPublished = text(after.status).toLowerCase() === 'published';
    if (wasPublished || !isPublished) return;

    const users = await usersWithRoles(['Resident']);
    const notification = {
      id: `announcement_${event.params.announcementId}`,
      type: 'announcement',
      referenceId: event.params.announcementId,
      title: text(after.title, 'New barangay announcement'),
      body: text(after.body || after.description),
    };
    await notifyUsers(users, notification);
  },
);

exports.notifyAdminsOfDocumentRequest = onDocumentCreated(
  { document: 'document_requests/{requestId}' },
  async (event) => {
    const data = event.data.data();
    const requestId = event.params.requestId;
    const documentType = text(data.documentType, 'document');
    const residentName = text(data.residentName, 'A resident');
    const users = await usersWithRoles(ADMIN_ROLES);
    const notification = {
      id: `document_request_${requestId}`,
      type: 'document_request',
      referenceId: requestId,
      title: 'New document request',
      body: `${residentName} submitted a ${documentType} request.`,
    };
    await notifyUsers(users, notification);
  },
);

exports.notifyResidentOfDocumentStatus = onDocumentUpdated(
  { document: 'document_requests/{requestId}' },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const oldStatus = text(before.status, 'Pending');
    const newStatus = text(after.status, 'Pending');
    if (oldStatus === newStatus) return;

    const residentId = text(after.residentId || after.requesterId);
    if (!residentId) return;
    const resident = await firestore.collection('users').doc(residentId).get();
    if (!resident.exists) return;

    const requestId = event.params.requestId;
    const notification = {
      id: `document_status_${requestId}_${newStatus.toLowerCase().replaceAll(' ', '_')}`,
      type: 'document_status',
      referenceId: requestId,
      title: 'Document request updated',
      body: `${text(after.documentType, 'Your document request')} is now ${newStatus}.`,
    };
    await notifyUsers([resident], notification);
  },
);

exports.notifyAdminsOfEmergencyReport = onDocumentCreated(
  { document: 'emergency_reports/{reportId}' },
  async (event) => {
    const data = event.data.data();
    const reportId = event.params.reportId;
    const reporterName = text(data.residentName, 'A resident');
    const reportType = text(data.type, 'Emergency report');
    const users = await usersWithRoles(ADMIN_ROLES);
    const notification = {
      id: `emergency_report_${reportId}`,
      type: 'emergency_report',
      referenceId: reportId,
      title: 'Emergency report received',
      body: `${reporterName} submitted a ${reportType}.`,
    };
    await notifyUsers(users, notification);
  },
);
