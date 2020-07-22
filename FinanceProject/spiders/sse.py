import os

import scrapy
import pandas as pd
import numpy as np


class SseSpider(scrapy.Spider):
    name = 'sse'
    # allowed_domains = ['www.sse.com.cn']
    start_urls = ['http://www.sse.com.cn/']

    # 动态生成初始 URL
    def start_requests(self):
        start_urls = []

        project_name = "FinanceProject"
        cur_path = os.path.abspath(os.path.dirname(__file__))
        root_path = cur_path[:cur_path.find(project_name + "\\") + len(project_name + "\\")]

        df = pd.read_excel(f'{root_path}申A.xlsx')
        cp_codes = np.array(df.iloc[:, 0:1]).T[0].tolist()

        for code in cp_codes:
            url = f'http://www.sse.com.cn/assortment/stock/list/info/company/index.shtml?COMPANY_CODE={code}'
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        print(response)
