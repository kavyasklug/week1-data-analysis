
import pandas as pd


def clean_superstore(df):
    cleaned_df = df.copy()

    cleaned_df['Product Name'] = cleaned_df['Product Name'].str.strip()

    cleaned_df['Order Date'] = pd.to_datetime(
        cleaned_df['Order Date'],
        format='%m/%d/%Y',
        errors='raise'
    )

    cleaned_df['Ship Date'] = pd.to_datetime(
        cleaned_df['Ship Date'],
        format='%m/%d/%Y',
        errors='raise'
    )

    cleaned_df['Postal Code'] = cleaned_df['Postal Code'].astype('string')

    return cleaned_df
