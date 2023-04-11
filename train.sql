select date_trunc('month', invoice_created_dt) day_ , service_name, 
surface_name,  sum(revenue) revenue 
from transactions
group by date_trunc('month', invoice_created_dt) , service_name,
surface_name

