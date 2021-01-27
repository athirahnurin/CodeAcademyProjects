import codecademylib
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
# print(ad_clicks.head())
view_count = ad_clicks.groupby('utm_source').user_id.count().reset_index()
# print(view_count)

ad_clicks['is_click']= ~ad_clicks.ad_click_timestamp.isnull()

clicks_by_source = ad_clicks.groupby(['utm_source','is_click']).user_id.count().reset_index()
# print(clicks_by_source)

clicks_pivot=clicks_by_source.pivot(
  columns = 'is_click',
  index='utm_source',
  values = 'user_id'
).reset_index()
# print(clicks_pivot)

clicks_pivot['percent_clicked'] = clicks_pivot[True] / (clicks_pivot[True]+ clicks_pivot[False])
# print(clicks_pivot)

# print(ad_clicks)
ad_shows = ad_clicks.groupby('experimental_group').user_id.count().reset_index()
# print(ad_shows)

a_b_is_click = ad_clicks.groupby(['experimental_group','is_click']).user_id.count().reset_index()
a_b_pivot = a_b_is_click.pivot(
  columns = 'is_click',
  index = 'experimental_group',
  values = 'user_id'
).reset_index()
# print(a_b_pivot)

a_clicks = ad_clicks[
   ad_clicks.experimental_group
   == 'A']

b_clicks = ad_clicks[
   ad_clicks.experimental_group
   == 'B']

# print(a_clicks,b_clicks)

a_clicks_group = a_clicks.groupby(['is_click','day']).user_id.count().reset_index()
b_clicks_group = a_clicks.groupby(['is_click','day']).user_id.count().reset_index()
a_clicks_group_pivot= a_clicks_group.pivot(
  columns ='is_click', 
  index = 'day',
  values = 'user_id'
).reset_index()

b_clicks_group_pivot= b_clicks_group.pivot(
  columns ='is_click', 
  index = 'day',
  values = 'user_id'
).reset_index()

# print(b_clicks_group_pivot)

a_clicks_group_pivot['Percentage Click']= a_clicks_group_pivot[True]/ (a_clicks_group_pivot[True]+ a_clicks_group_pivot[False])

b_clicks_group_pivot['Percentage Click'] = b_clicks_group_pivot[True]/ (b_clicks_group_pivot[True] + b_clicks_group_pivot[False])

print(a_clicks_group_pivot,b_clicks_group_pivot)












