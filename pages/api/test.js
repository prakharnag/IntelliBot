module.exports = (req, res) => {
    console.log("Test endpoint invoked", req.query);
    res.status(200).json({ message: "API is working!" });
  };