select * from favorites f ;

SELECT p.id, p.title, p.description, p.price, p.is_available, p.is_bestseller, p.is_featured,
        COALESCE(json_agg(pi.image_url) FILTER (WHERE pi.image_url IS NOT NULL), '[]') AS images
      FROM favorites f
      JOIN products p ON f.product_id = p.id
      LEFT JOIN product_images pi ON p.id = pi.product_id
      GROUP BY p.id
      ORDER BY p.created_at DESC;