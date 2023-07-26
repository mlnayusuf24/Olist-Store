# Brazilian E-Commerce Olist Store
![Alt text](https://github.com/mlnayusuf24/Olist-Store/blob/main/images/dataset-cover.png)

## About Dataset
The dataset contains information on 100k orders made at multiple marketplaces in Brazil from 2016 to 2018. Its features allow for viewing orders from various dimensions, including order status, price, payment and freight performance, customer location, product attributes, and customer reviews. Additionally, we have released a geolocation dataset that maps Brazilian zip codes to latitude/longitude coordinates. You can download the dataset [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The data is divided into multiple datasets for better understanding and organization. Refer to the following data schema when working with it:
![Alt text](https://github.com/mlnayusuf24/Olist-Store/blob/e1b04600fbcda82d7f555d7b1efd8ee38468ae54/images/olist_dataset_scheme.png)
- olist_customer_dataset: This dataset has information about the customer and its location. Use it to identify unique customers in the orders dataset and to find the order's delivery location.
- olist_geolocation_dataset: This dataset has information on Brazilian zip codes and their lat/long coordinates. Use it to plot maps and find distances between sellers and customers.
- olist_order_items_dataset: This dataset includes data about the items purchased within each order.
- olist_order_payments_dataset: This dataset includes data about the order payment options.
- olist_orders_dataset: This is the core dataset. From each order, you might find all the other information.
- olist_products_dataset: This dataset includes data about the products sold by Olist.
- olist_sellers_dataset: This dataset includes data about the sellers that fulfilled orders made at Olist. Use it to find the seller's location and to identify which seller fulfilled each product.
- product_category_name_translation: Translates the product_category_name to english.


Medium: [Link](https://mlnayusuf24.medium.com/olist-store-exploratory-data-analysis-using-sql-63ca3c4b7a87),
Tableau: [Link](https://public.tableau.com/views/E-CommerceDashboard_16859680703300/ExecutiveSummary?:language=en-US&:display_count=n&:origin=viz_share_link)
