-- Temporary verification file for the OpenCodeReview workflow.
SELECT
    order_id,
    CAST(total_amount AS INTEGER) AS total_amount_int,
    d.status
FROM orders o
JOIN deliveries d ON d.order_id = o.id
WHERE o.status <> 'cancelled'
    AND o.created_at >= NOW() - INTERVAL '7 days'
ORDER BY o.created_at DESC
LIMIT 100;
