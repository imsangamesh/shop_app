const express = require("express");
const app = express();

const Stripe = require("stripe");

const key =
  "sk_test_51PDuoKSB3Rv2kJaTWAhYHtJhITbLcszccEUI3VUZW9WbnsDblwPud2OYl3R0QxkhQC4REa0BNDrrLgaA91J90mZ700TiDsGvSx";
const stripe = new Stripe(key);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.post("/api/payment", async (req, res) => {
  const { body } = req;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: body?.amount,
      currency: body?.currency,
      payment_method_types: ["card"],
    });

    if (paymentIntent?.status != "completed") {
      console.log("------------------------- NOT COMPLETED");
      return res.status(200).json({
        message: "Confirm payment please",
        client_secret: paymentIntent?.client_secret,
      });
    }

    console.log("------------------------- COMPLETED");
    return res.status(200).json({ message: "Payment Completed Successfully!" });
  } catch (error) {
    console.log("ERROR: " + error);
  }
});

app.listen(3000, () => console.log(`Port listening on ${3000}`));
