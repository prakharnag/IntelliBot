export default async function handler(req, res) {
    // Handle preflight CORS request
    if (req.method === 'OPTIONS') {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
      res.status(200).end();
      return;
    }
  
    const { url } = req.query;
  
    if (!url) {
      res.status(400).json({ error: 'Missing url parameter' });
      return;
    }
  
    try {
      const response = await fetch(url);
  
      if (!response.ok) {
        res.status(response.status).send('Failed to fetch image');
        return;
      }
  
      // Forward content type (important for image rendering)
      res.setHeader('Content-Type', response.headers.get('content-type'));
  
      // ✅ Add CORS headers
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
      const buffer = await response.arrayBuffer();
      res.status(200).send(Buffer.from(buffer));
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
  