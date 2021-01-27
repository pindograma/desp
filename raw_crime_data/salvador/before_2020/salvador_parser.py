# salvador_parser.py
# (c) 2021 CincoNoveSeis Jornalismo Ltda.
#
# This code is licensed under the GNU General Public License,
# version 3.

import csv
from collections import OrderedDict
from pathlib import Path

from pdfminer.layout import LTTextBox, LTTextBoxHorizontal, LAParams
from pdfminer.converter import PDFPageAggregator
from pdfminer.pdfinterp import PDFPageInterpreter, PDFResourceManager
from pdfminer.pdfpage import PDFPage

crimes = ['Homicídio Doloso', 'Lesão Corporal Seguida de Morte', 'Latrocínio',
          'Tentativa de Homicídio', 'Estupro', 'Roubo a Ônibus', 'Roubo de Veículo',
          'Furto de Veículo', 'Uso/Porte Entorpecente']

def extract_pages(pdf_file, page_numbers=None,
                    maxpages=0, password='',
                    check_extractable=False, caching=True):
    with open(pdf_file, 'rb') as fp:
        laparams = LAParams()
        resource_manager = PDFResourceManager()
        device = PDFPageAggregator(resource_manager, laparams=laparams)
        interpreter = PDFPageInterpreter(resource_manager, device)
        for page in PDFPage.get_pages(fp, page_numbers, maxpages=maxpages,
                                      password=password, caching=caching,
                                      check_extractable = check_extractable):
            interpreter.process_page(page)
            layout = device.get_result()
            yield layout

def main():
    output = {}
    
    files = Path('.').glob('*.pdf')

    for f in files:
        page = next(extract_pages(f))
        
        date = None
        aispheights = {}
        aispstats = {1: {}, 2: {}, 3: {}, 4: {}, 5: {}, 6: {}, 7: {}, 8: {}, 9: {},
                     10: {}, 11: {}, 12: {}, 13: {}, 14: {}, 15: {}, 16: {}}
        aispstats_final = {1: {}, 2: {}, 3: {}, 4: {}, 5: {}, 6: {}, 7: {}, 8: {}, 9: {},
                     10: {}, 11: {}, 12: {}, 13: {}, 14: {}, 15: {}, 16: {}}

        for element in page:
            if isinstance(element, LTTextBoxHorizontal):
                if element.get_text().startswith('PRINCIPAIS DELITOS'):
                    date = element.get_text().split('\n')[1]

                if element.get_text().startswith('AISP'):
                    aispheights[int(element.get_text().strip()[5:7])] = (element.bbox[1], element.bbox[3])

        for element in page:
            if isinstance(element, LTTextBoxHorizontal):
                if element.get_text().strip().isdigit():
                    for aisp, heights in aispheights.items():
                        if element.bbox[1] == heights[0] and element.bbox[3] == heights[1]:
                            aispstats[aisp][element.bbox[0]] = int(element.get_text().strip())

        for k, v in aispstats.items():
            aispstats_final[k] = OrderedDict(sorted(v.items()))
            aispstats_final[k] = {k: v for k, v in zip(crimes, aispstats_final[k].values())}

        print(aispstats_final)
        output[date] = aispstats_final

    csv_output = []

    for k, v in output.items():
        for k2, v2 in v.items():
            for k3, v3 in v2.items():
                csv_output.append({
                    'date': k,
                    'aisp': k2,
                    'crime': k3,
                    'occurrences': v3
                })

    with open('salvador_crimes.csv', 'w', newline='') as output_file:
        dict_writer = csv.DictWriter(output_file, csv_output[0].keys())
        dict_writer.writeheader()
        dict_writer.writerows(csv_output)

main()
