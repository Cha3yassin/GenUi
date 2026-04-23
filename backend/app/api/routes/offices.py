"""
api/routes/offices.py - Public office location endpoints.
"""

from math import asin, cos, radians, sin, sqrt
from typing import Optional

from fastapi import APIRouter, Query

router = APIRouter(prefix="/offices", tags=["Offices"])

_DEFAULT_LAT = 36.8065
_DEFAULT_LNG = 10.1815

_OFFICES = [
    {
        "id": "attt-tunis",
        "name": "ATTT - Centre de visite technique Tunis",
        "type": "Véhicules",
        "address": "Avenue de la République, Tunis",
        "workingHours": "Lun-Ven 08:00 - 16:30",
        "isOpen": True,
        "lat": 36.8008,
        "lng": 10.1800,
        "keywords": ["vehicles", "car", "voiture", "carte grise", "permis", "mutation"],
    },
    {
        "id": "municipalite-tunis",
        "name": "Municipalité de Tunis - État civil",
        "type": "État Civil",
        "address": "2 Rue du 2 Mars 1934, Tunis",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 36.7992,
        "lng": 10.1715,
        "keywords": ["civil_status", "naissance", "cin", "passeport", "etat civil"],
    },
    {
        "id": "rne-tunis",
        "name": "Registre National des Entreprises - Tunis",
        "type": "Entreprises",
        "address": "Rue du Lac d'Annecy, Les Berges du Lac, Tunis",
        "workingHours": "Lun-Ven 08:30 - 16:30",
        "isOpen": True,
        "lat": 36.8368,
        "lng": 10.2380,
        "keywords": ["business", "entreprise", "rne", "registre", "company"],
    },
    {
        "id": "recette-finances-tunis",
        "name": "Recette des Finances - Tunis",
        "type": "Fiscalité",
        "address": "Avenue Habib Bourguiba, Tunis",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 36.8000,
        "lng": 10.1840,
        "keywords": ["taxation", "fiscalité", "impot", "taxe", "timbre"],
    },
    {
        "id": "cnss-tunis",
        "name": "CNSS - Bureau régional Tunis",
        "type": "Sécurité Sociale",
        "address": "49 Avenue Taieb Mehiri, Tunis",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 36.8096,
        "lng": 10.1777,
        "keywords": ["social_security", "cnss", "sécurité sociale"],
    },
    {
        "id": "office-topographie-tunis",
        "name": "Office de la Topographie et du Cadastre - Tunis",
        "type": "Immobilier",
        "address": "Rue de Syrie, Tunis",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 36.8060,
        "lng": 10.1710,
        "keywords": ["property", "immobilier", "cadastre", "titre foncier"],
    },
]


@router.get("/nearby")
async def nearby_offices(
    stepId: Optional[str] = Query(default=None, max_length=100),
    lat: Optional[float] = Query(default=None, ge=-90, le=90),
    lng: Optional[float] = Query(default=None, ge=-180, le=180),
) -> list[dict]:
    origin_lat = lat if lat is not None else _DEFAULT_LAT
    origin_lng = lng if lng is not None else _DEFAULT_LNG

    offices = _filter_offices(stepId)
    enriched = []
    for office in offices:
        distance_km = _distance_km(origin_lat, origin_lng, office["lat"], office["lng"])
        enriched.append(
            {
                "id": office["id"],
                "name": office["name"],
                "type": office["type"],
                "address": office["address"],
                "workingHours": office["workingHours"],
                "isOpen": office["isOpen"],
                "lat": office["lat"],
                "lng": office["lng"],
                "distance": f"{distance_km:.1f} km",
            }
        )

    return sorted(enriched, key=lambda item: float(item["distance"].split()[0]))[:6]


def _filter_offices(step_id: Optional[str]) -> list[dict]:
    if not step_id:
        return _OFFICES

    needle = step_id.lower().replace("-", " ").replace("_", " ")
    matches = [
        office
        for office in _OFFICES
        if any(keyword.lower() in needle or needle in keyword.lower() for keyword in office["keywords"])
    ]
    return matches or _OFFICES


def _distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    earth_radius_km = 6371.0
    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)
    a = (
        sin(dlat / 2) ** 2
        + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2) ** 2
    )
    return 2 * earth_radius_km * asin(sqrt(a))
