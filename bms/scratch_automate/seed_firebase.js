const { initializeApp } = require('firebase/app');
const { getFirestore, doc, setDoc, Timestamp } = require('firebase/firestore');

const firebaseConfig = {
  projectId: "bms-system-2499a",
  apiKey: "AIzaSyAPFnyLbNDTmkSYY8nhiMWpdf9olFIN_3o",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function writeFirestore(collection, docId, fields) {
  console.log(`  Writing Firestore: ${collection}/${docId}...`);
  try {
    await setDoc(doc(db, collection, docId), fields);
    console.log(`  Written OK.`);
    return true;
  } catch (e) {
    console.error(`  Firestore write failed:`, e.message);
    return false;
  }
}

async function run() {
  console.log('=== BMS Firebase Seed Script (Client SDK) ===\n');

  const adminUid = 'bvGFi0X9doWa7g0ZSDt7tgNTfk23';
  const residentUid = '3gmERSwjK6TxHeeIP9ZOXf0N1Nt1';

  console.log('\n--- Seeding Firestore user documents ---');
  await writeFirestore('users', adminUid, {
    uid: adminUid,
    email: 'admin@barangay.gov.ph',
    displayName: 'Barangay Chairman',
    role: 'Chairman',
    createdAt: new Date().toISOString(),
  });

  await writeFirestore('users', residentUid, {
    uid: residentUid,
    email: 'resident@gmail.com',
    displayName: 'Juan Dela Cruz',
    role: 'Resident',
    address: '123 Sampaguita St., Brgy. San Jose',
    createdAt: new Date().toISOString(),
  });

  console.log('\n--- Seeding announcements ---');
  const announcements = [
    {
      id: 'ann1',
      title: 'Barangay Assembly Meeting',
      content: 'All residents are invited to the quarterly barangay assembly meeting. Topics include infrastructure updates, peace and order, and health programs.',
      date: 'August 15, 2026',
      category: 'Meeting',
      status: 'published',
      createdAt: new Date().toISOString(),
    },
    {
      id: 'ann2',
      title: 'Free Medical Mission',
      content: 'The barangay health center will conduct a free medical mission for all residents. Services include blood pressure check, blood sugar test, and general consultation.',
      date: 'August 20, 2026',
      category: 'Health',
      status: 'published',
      createdAt: new Date(Date.now() - 86400000).toISOString(),
    },
    {
      id: 'ann3',
      title: 'Road Rehabilitation Notice',
      content: 'Please be advised that road rehabilitation works will begin on August 25. Expect traffic rerouting along Rizal Ave. during construction.',
      date: 'August 25, 2026',
      category: 'Infrastructure',
      status: 'published',
      createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
    },
  ];

  for (const ann of announcements) {
    const { id, ...fields } = ann;
    await writeFirestore('announcements', id, fields);
  }

  console.log('\n--- Seeding document requests ---');
  const requests = [
    {
      id: 'req1',
      residentUid: residentUid,
      residentName: 'Juan Dela Cruz',
      email: 'resident@gmail.com',
      documentType: 'Barangay Clearance',
      purpose: 'Employment',
      status: 'Pending',
      createdAt: new Date().toISOString(),
    },
    {
      id: 'req2',
      residentUid: residentUid,
      residentName: 'Juan Dela Cruz',
      email: 'resident@gmail.com',
      documentType: 'Certificate of Residency',
      purpose: 'School Enrollment',
      status: 'In Review',
      createdAt: new Date(Date.now() - 3 * 86400000).toISOString(),
    },
    {
      id: 'req3',
      residentUid: residentUid,
      residentName: 'Juan Dela Cruz',
      email: 'resident@gmail.com',
      documentType: 'Barangay Indigency',
      purpose: 'Medical Assistance',
      status: 'Completed',
      createdAt: new Date(Date.now() - 7 * 86400000).toISOString(),
    },
  ];

  for (const req of requests) {
    const { id, ...fields } = req;
    await writeFirestore('document_requests', id, fields);
  }

  console.log('\n=== Seeding Complete! ===');
  process.exit(0);
}

run().catch(console.error);
