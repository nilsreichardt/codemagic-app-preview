import * as functions from "firebase-functions/v2";
import * as QRCode from "qrcode";
import * as admin from "firebase-admin";

admin.initializeApp();

functions.setGlobalOptions({
  region: "europe-west3",
});

/**
 * HTTP Cloud Function to Generate and Return a QR Code Image.
 *
 * @function
 * @async
 * @param {Object} req - The HTTP request object, containing query parameters.
 *  - @param {string} req.query.data - The data to be encoded in the QR code.
 *  - @param {string} req.query.size - The size of the generated QR code image.
 *  - @param {string} req.query.platform - The platform identifier for analytics
 *    (e.g., "android" or "ios").
 *  - @param {string} req.query.groupId - The group ID to identify QR codes from
 *    the same build.
 * @param {Object} res - The HTTP response object.
 * @returns {void} Sends a QR code image in response to a valid request, or an
 * error message for invalid parameters or internal server errors.
 * @throws {400} Throws a 400 error if the parameters are invalid.
 * @throws {500} Throws a 500 error if an internal server error occurs.
 *
 * This function generates a QR code image based on the provided `data` and
 * `size`. It also logs analytics information, including the `platform` and
 * `groupId`, to Firestore. The `groupId` helps identify QR codes that belong to
 * a specific group or build.
 */
exports.createQrCode = functions.https.onRequest(async (req, res) => {
  try {
    const size = parseInt(req.query.size as string);
    const data = req.query.data as string;
    const platform = req.query.platform as string;
    const groupId = req.query.groupId as string;

    if (isNaN(size) || !data || !platform || !groupId) {
      res.status(400).send("Invalid parameters");
      return;
    }

    const result = await Promise.all([
      generateQrCode(data, size),
      logAnalytics(platform, groupId),
    ]);
    
    const qrPng = result[0];
    res.type("image/png").send(qrPng);
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
  }
});

function generateQrCode(data: string, size: number) {
  return QRCode.toBuffer(data, { type: "png", width: size });
}

async function logAnalytics(platform: string, groupId: string) {
  const firestore = admin.firestore();
  await firestore.collection("analytics").add({
    createdAt: new Date(),
    platform: platform,
    groupId: groupId,
  });
}
