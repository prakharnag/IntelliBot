export default async (req, res) => {
    // Retrieve the external image URL from the query parameter "url"
    const { url } = req.query;
    if (!url) {
      return res.status(400).json({ error: "Missing 'url' query parameter" });
    }
  
    try {
      // Fetch the image from the external URL
      const externalResponse = await fetch(url);
      if (!externalResponse.ok) {
        return res
          .status(externalResponse.status)
          .json({ error: "Failed to fetch image" });
      }
  
      // Get the image data as an array buffer
      const buffer = await externalResponse.arrayBuffer();
  
      // Set the proper content type (adjust if needed) and allow CORS for all origins
      res.setHeader("Content-Type", "image/png");
      res.setHeader("Access-Control-Allow-Origin", "*");
  
      // Return the image data as a Buffer
      res.status(200).send(Buffer.from(buffer));
    } catch (error) {
      console.error("Error in image-proxy:", error);
      res.status(500).json({ error: error.message });
    }
  };