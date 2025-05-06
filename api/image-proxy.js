export default async function handler(req, res) {
    const { url } = req.query;
  
    if (!url) {
      return res.status(400).json({ error: 'Missing url query param' });
    }
  
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch image');
  
      res.setHeader('Content-Type', response.headers.get('content-type'));
      const buffer = await response.arrayBuffer();
      res.send(Buffer.from(buffer));
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
  