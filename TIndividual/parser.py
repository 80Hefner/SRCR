import pandas
import re
from math import radians, sin, cos, sqrt, atan2
from pathlib import Path


def calculateDistance(lat1, long1, lat2, long2):
    earth_radius = 6371.0

    lat1 = radians(lat1)
    long1 = radians(long1)
    lat2 = radians(lat2)
    long2 = radians(long2)

    dlon = long2 - long1
    dlat = lat2 - lat1

    a = (sin(dlat/2))**2 + cos(lat1) * cos(lat2) * (sin(dlon/2))**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))

    return earth_radius*c

dataset_path = Path("dataset.xlsx").resolve()
dataset = pandas.read_excel(dataset_path)

datasetData = {}
datasetDataByResidues = {
    'Lixos': {},
    'Vidro': {},
    'Papel e Cartão': {},
    'Embalagens': {},
    'Organicos': {}
}

pointsFile = open("pontos_recolha.pl", "w", encoding="UTF-8")
pointsFile.write("%%pontos_recolha(latitude, longitude, local, resíduo, total_litros, [destinos]).\n\n")

arcsFile = open("arcos.pl", "w", encoding="UTF-8")
arcsFile.write("%%arco(local 1, local 2, distancia).\n\n")


for line in dataset.values:

    # parse line parameters
    latitude = line[0]
    longitude = line[1]
    collection_point = line[2]
    residue = line[3]
    total_liters = line[4]    

    # get collection point from line and parse its name
    res = re.search(r'([\w, -\/]+)(\[(.*)\])?', collection_point)

    # get only name of the street and remove extra spaces
    local = re.split(r',', res[1])[0]
    if local[-1] == " ":
        local = local[:-1]

    # insert into datasetData dictionary
    if local not in datasetData:
        datasetData[local] = {
            'latitude':latitude,
            'longitude':longitude,
            'destinations':[],
            'total_liters':0
        }
    datasetData[local]['total_liters'] += total_liters

    # insert into datasetDataByResidues dictionary
    if local not in datasetDataByResidues[residue]:
        datasetDataByResidues[residue][local] = {
            'latitude':latitude,
            'longitude':longitude,
            'destinations':[],
            'total_liters':0
            }
    datasetDataByResidues[residue][local]['total_liters'] += total_liters

    # parse destinations
    routes = ""
    if res[3] is not None:
        destinations = re.split(r' *, *', res[3])
        for dest in destinations:
            routes += "'" + dest + "',"
            datasetDataByResidues[residue][local]['destinations'].append(dest)
            if dest not in datasetData[local]['destinations']:
                datasetData[local]['destinations'].append(dest)
        # remove extra ',' in the end
        routes = routes[:-1]

    # write collection point to file
    pointsFile.write("pontos_recolha("  + str(latitude)
                                   + ", "  + str(longitude)
                                   + ", '" + local + "'"
                                   + ", '" + residue + "'"
                                   + ", "  + str(total_liters)
                                   + ", [" + str(routes)
                                   + "]).\n")


checked = {}

for (local,value) in datasetData.items():
    checked[local] = []
    for dest in value['destinations']:
        if (dest not in checked) or (dest in checked and local not in checked[dest]):
            checked[local].append(dest)
            if dest in datasetData:
                distance = calculateDistance(value['latitude'],value['longitude'],
                                                datasetData[dest]['latitude'],
                                                datasetData[dest]['longitude'])
                if distance > 0:
                    arcsFile.write("arco(" + "'" + local + "'" +
                                    ", '" + dest + "'" +
                                    ", " + str(distance) +
                                    ").\n")

pointsFile.close
arcsFile.close
