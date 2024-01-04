import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import * as QRCode from "qrcode";
// Using the import because of https://stackoverflow.com/q/73079648/8358501.
import { logger } from "firebase-functions/v2";

admin.initializeApp();

// Using "europe-west3" even it's more expensive because it might be faster
// because Firestore is set to "europe-west3" as well.
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
 *  - @param {string} req.query.platform (optional) - The platform identifier
 *    for analytics (e.g., "android" or "ios").
 *  - @param {string} req.query.groupId (optional) - The group ID to identify QR
 *    codes from the same build.
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
    const platform = req.query.platform as string | undefined;
    const groupId = req.query.groupId as string | undefined;

    if (isNaN(size) || !data) {
      res.status(400).send("Invalid parameters");
      return;
    }

    const result = await Promise.all([
      generateQrCode(data, size),
      logAnalytics(platform, groupId),
    ]);

    logger.info("QR code generated successfully", {
      size: size,
      platform: platform,
      groupId: groupId,
    });

    const qrPng = result[0];
    res.type("image/png").send(qrPng);
  } catch (err) {
    console.error("Error while generating QR code", {
      error: err,
      platform: req.query.platform,
      groupId: req.query.groupId,
    });
    res.status(500).send("Internal Server Error");
  }
});

function generateQrCode(data: string, size: number) {
  return QRCode.toBuffer(data, { type: "png", width: size });
}

async function logAnalytics(
  platform: string | undefined,
  groupId: string | undefined,
) {
  if (!platform || !groupId) {
    // Don't log analytics if the platform or groupId is not provided.
    return;
  }

  await admin.firestore().collection("QrActivities").doc().set({
    createdAt: new Date(),
    platform: platform,
    groupId: groupId,
  });
}
