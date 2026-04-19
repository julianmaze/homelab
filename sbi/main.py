#!/usr/bin/env python3
from datetime import datetime as dt
import logging as log
import math
import os
import sys
import yfinance as yf
import json

TICKERS_FILE_PATH = "./tickers.txt"
STATEMENT_FREQUENCY = "quarterly"
# PRICE_FREQUENCY = "1mo"
PRICE_FREQUENCY = "max"
PRICE_MAX_FREQUENCY = [] # List of tickers for which we want to get max history price data instead of 1mo. This should only be used to seed the database
PARENT_DIR = dt.now().strftime("%Y-%m-%d_%H-%M")

log.basicConfig(
    level=log.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)

def convert_nan_to_none(obj):
    """Recursively convert NaN values to None for JSON serialization"""
    if isinstance(obj, dict):
        return {k: convert_nan_to_none(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_nan_to_none(item) for item in obj]
    elif isinstance(obj, float) and math.isnan(obj):
        return None
    return obj

def main():
    log.info("Creating parent directory if it does not exist: " + PARENT_DIR)
    os.makedirs(PARENT_DIR, exist_ok=True)

    log.info("Opening " + TICKERS_FILE_PATH)
    with open(TICKERS_FILE_PATH, 'r') as f:
        tickers = f.read()
    log.info(len(tickers.splitlines()))

    log.info("Gathering financial info for each ticker. Processing...")
    stock_data_info = []
    for t in tickers.splitlines():
        log.info("  " + t)
        dat = yf.Ticker(t)      
        stock_data_info.append({"ticker": t, "data": dat})

    log.info("Get dividend data for each ticker and dump it to a file")
    os.makedirs(PARENT_DIR + "/dividends", exist_ok=True)
    for s in stock_data_info:
        log.info("  " + s["ticker"])
        div = s["data"].dividends.to_dict()
        div_serializable = {str(k): v for k, v in div.items()}
        div_clean = convert_nan_to_none(div_serializable)
        with open(PARENT_DIR + "/dividends/" + s["ticker"] + "_dividends.json", 'w') as f:
            json.dump(div_clean, f, indent=2)

    log.info("Get info data for each ticker and dump it to a file")
    os.makedirs(PARENT_DIR + "/info", exist_ok=True)
    for s in stock_data_info:
        log.info("  " + s["ticker"])
        info = s["data"].info
        info_clean = convert_nan_to_none(info)
        with open(PARENT_DIR + "/info/" + s["ticker"] + "_info.json", 'w') as f:
            json.dump(info_clean, f, indent=2)

    log.info("Get cashflow data for each ticker and dump it to a file")
    os.makedirs(PARENT_DIR + "/cashflow", exist_ok=True)
    for s in stock_data_info:
        log.info("  " + s["ticker"])
        cashflow = s["data"].get_cashflow(as_dict=True, freq=STATEMENT_FREQUENCY)
        # Convert Timestamp keys to strings for JSON serialization
        cashflow_serializable = {str(k): v for k, v in cashflow.items()}
        cashflow_clean = convert_nan_to_none(cashflow_serializable)
        with open(PARENT_DIR + "/cashflow/" + s["ticker"] + "_cashflow.json", 'w') as f:
            json.dump(cashflow_clean, f, indent=2)

    log.info("Get balancesheet data for each ticker and dump it to a file")
    os.makedirs(PARENT_DIR + "/balancesheet", exist_ok=True)
    for s in stock_data_info:
        log.info("  " + s["ticker"])
        balancesheet = s["data"].get_balancesheet(as_dict=True, freq=STATEMENT_FREQUENCY)
        # Convert Timestamp keys to strings for JSON serialization
        balancesheet_serializable = {str(k): v for k, v in balancesheet.items()}
        balancesheet_clean = convert_nan_to_none(balancesheet_serializable)
        with open(PARENT_DIR + "/balancesheet/" + s["ticker"] + "_balancesheet.json", 'w') as f:
            json.dump(balancesheet_clean, f, indent=2)

    log.info("Get stock price data for each ticker and dump it to a file")
    os.makedirs(PARENT_DIR + "/stock_price", exist_ok=True)
    for s in stock_data_info:
        log.info("  " + s["ticker"])
        if s["ticker"] in PRICE_MAX_FREQUENCY:
            log.info("    Getting max history price data for " + s["ticker"])
            stock_price = s["data"].history(period="max").to_dict()
        else:
            stock_price = s["data"].history(period=PRICE_FREQUENCY).to_dict()
        # Convert nested Timestamp keys to strings
        stock_price_serializable = {str(k): {str(date): val for date, val in v.items()} for k, v in stock_price.items()}
        stock_price_clean = convert_nan_to_none(stock_price_serializable)
        with open(PARENT_DIR + "/stock_price/" + s["ticker"] + "_stock_price.json", 'w') as f:
            json.dump(stock_price_clean, f, indent=2)

if __name__ == "__main__":
    main()
