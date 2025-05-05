// filepath: /api/image-proxy.js
module.exports = async (req, res) => {
    console.log("image-proxy function invoked", req.query);
    const { url } = req.query;
    if (!url) {
      return res.status(400).json({ error: "Missing 'url' query parameter" });
    }
    try {
      const externalResponse = await fetch(url);
      console.log("Fetched external URL status:", externalResponse.status);
      if (!externalResponse.ok) {
        return res
          .status(externalResponse.status)
          .json({ error: "Failed to fetch image" });
      }
      const buffer = await externalResponse.arrayBuffer();
      res.setHeader("Content-Type", "image/png");
      res.setHeader("Access-Control-Allow-Origin", "*");
      return res.status(200).send(Buffer.from(buffer));
    } catch (error) {
      console.error("Error in image-proxy:", error);
      return res.status(500).json({ error: error.message });
    }
  };