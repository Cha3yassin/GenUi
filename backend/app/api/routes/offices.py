"""
api/routes/offices.py - Public office location endpoints.
"""

import re
from math import asin, cos, radians, sin, sqrt
from typing import Optional

from fastapi import APIRouter, Query

router = APIRouter(prefix="/offices", tags=["Offices"])

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
    {
        "id": "rne-sfax",
        "name": "Registre National des Entreprises - Sfax",
        "type": "Entreprises",
        "address": "Route de Gremda, Sfax",
        "workingHours": "Lun-Ven 08:30 - 16:30",
        "isOpen": True,
        "lat": 34.7398,
        "lng": 10.7600,
        "keywords": ["business", "entreprise", "rne", "registre", "company"],
    },
    {
        "id": "recette-finances-sousse",
        "name": "Recette des Finances - Sousse",
        "type": "Fiscalité",
        "address": "Avenue Habib Bourguiba, Sousse",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 35.8288,
        "lng": 10.6403,
        "keywords": ["taxation", "fiscalité", "impot", "taxe", "timbre", "tva"],
    },
    {
        "id": "cnss-sousse",
        "name": "CNSS - Bureau régional Sousse",
        "type": "Sécurité Sociale",
        "address": "Boulevard du 14 Janvier, Sousse",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 35.8308,
        "lng": 10.6387,
        "keywords": ["social_security", "cnss", "sécurité sociale", "cnam", "retraite"],
    },
    {
        "id": "municipalite-nabeul",
        "name": "Municipalité de Nabeul - État civil",
        "type": "État Civil",
        "address": "Avenue Habib Thameur, Nabeul",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 36.4540,
        "lng": 10.7350,
        "keywords": ["civil_status", "naissance", "cin", "passeport", "etat civil"],
    },
    {
        "id": "attt-sfax",
        "name": "ATTT - Centre de visite technique Sfax",
        "type": "Véhicules",
        "address": "Route de l'Aéroport, Sfax",
        "workingHours": "Lun-Ven 08:00 - 16:30",
        "isOpen": True,
        "lat": 34.7431,
        "lng": 10.7580,
        "keywords": ["vehicles", "car", "voiture", "carte grise", "permis", "mutation"],
    },
    {
        "id": "attt-sousse",
        "name": "ATTT - Centre de visite technique Sousse",
        "type": "Véhicules",
        "address": "Route de Monastir, Sousse",
        "workingHours": "Lun-Ven 08:00 - 16:30",
        "isOpen": True,
        "lat": 35.8382,
        "lng": 10.6259,
        "keywords": ["vehicles", "car", "voiture", "carte grise", "permis", "mutation"],
    },
    {
        "id": "attt-gabes",
        "name": "ATTT - Centre de visite technique Gabès",
        "type": "Véhicules",
        "address": "Avenue de l'Environnement, Gabès",
        "workingHours": "Lun-Ven 08:00 - 16:30",
        "isOpen": True,
        "lat": 33.8886,
        "lng": 10.0982,
        "keywords": ["vehicles", "car", "voiture", "carte grise", "permis", "mutation"],
    },
    {
        "id": "municipalite-sfax",
        "name": "Municipalité de Sfax - État civil",
        "type": "État Civil",
        "address": "Place de la Municipalité, Sfax",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 34.7410,
        "lng": 10.7603,
        "keywords": ["civil_status", "naissance", "cin", "passeport", "etat civil"],
    },
    {
        "id": "municipalite-sousse",
        "name": "Municipalité de Sousse - État civil",
        "type": "État Civil",
        "address": "Rue de la Kasbah, Sousse",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 35.8256,
        "lng": 10.6369,
        "keywords": ["civil_status", "naissance", "cin", "passeport", "etat civil"],
    },
    {
        "id": "rne-sousse",
        "name": "Registre National des Entreprises - Sousse",
        "type": "Entreprises",
        "address": "Avenue Yasser Arafat, Sousse",
        "workingHours": "Lun-Ven 08:30 - 16:30",
        "isOpen": True,
        "lat": 35.8394,
        "lng": 10.6316,
        "keywords": ["business", "entreprise", "rne", "registre", "company"],
    },
    {
        "id": "rne-gabes",
        "name": "Registre National des Entreprises - Gabès",
        "type": "Entreprises",
        "address": "Avenue Habib Thameur, Gabès",
        "workingHours": "Lun-Ven 08:30 - 16:30",
        "isOpen": True,
        "lat": 33.8815,
        "lng": 10.1059,
        "keywords": ["business", "entreprise", "rne", "registre", "company"],
    },
    {
        "id": "recette-finances-sfax",
        "name": "Recette des Finances - Sfax",
        "type": "Fiscalité",
        "address": "Avenue Hédi Chaker, Sfax",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 34.7372,
        "lng": 10.7530,
        "keywords": ["taxation", "fiscalité", "impot", "taxe", "timbre", "tva"],
    },
    {
        "id": "recette-finances-gafsa",
        "name": "Recette des Finances - Gafsa",
        "type": "Fiscalité",
        "address": "Avenue de la Liberté, Gafsa",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 34.4250,
        "lng": 8.7842,
        "keywords": ["taxation", "fiscalité", "impot", "taxe", "timbre", "tva"],
    },
    {
        "id": "cnss-sfax",
        "name": "CNSS - Bureau régional Sfax",
        "type": "Sécurité Sociale",
        "address": "Avenue Majida Boulila, Sfax",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 34.7443,
        "lng": 10.7546,
        "keywords": ["social_security", "cnss", "sécurité sociale", "cnam", "retraite"],
    },
    {
        "id": "cnss-gabes",
        "name": "CNSS - Bureau régional Gabès",
        "type": "Sécurité Sociale",
        "address": "Avenue de l'Indépendance, Gabès",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 33.8921,
        "lng": 10.1025,
        "keywords": ["social_security", "cnss", "sécurité sociale", "cnam", "retraite"],
    },
    {
        "id": "office-topographie-sfax",
        "name": "Office de la Topographie et du Cadastre - Sfax",
        "type": "Immobilier",
        "address": "Route de Mahdia, Sfax",
        "workingHours": "Lun-Ven 08:00 - 14:00",
        "isOpen": True,
        "lat": 34.7523,
        "lng": 10.7725,
        "keywords": ["property", "immobilier", "cadastre", "titre foncier"],
    },
]


@router.get("/nearby")
async def nearby_offices(
    stepId: Optional[str] = Query(default=None, max_length=100),
    lat: Optional[float] = Query(default=None, ge=-90, le=90),
    lng: Optional[float] = Query(default=None, ge=-180, le=180),
) -> list[dict]:
    offices = _filter_offices(stepId)
    if lat is None or lng is None:
        # No user location yet: return a diversified nationwide sample
        return [
            {
                "id": office["id"],
                "name": office["name"],
                "type": office["type"],
                "address": office["address"],
                "workingHours": office["workingHours"],
                "isOpen": office["isOpen"],
                "lat": office["lat"],
                "lng": office["lng"],
                "distance": "--",
            }
            for office in offices[:12]
        ]

    origin_lat = lat
    origin_lng = lng
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
    need_tokens = _normalise_tokens(needle)
    if not need_tokens:
        return _OFFICES

    matches = []
    for office in _OFFICES:
        score = _keyword_match_score(need_tokens, office["keywords"])
        if score > 0:
            matches.append((score, office))

    matches.sort(key=lambda item: item[0], reverse=True)
    top_matches = [office for _, office in matches]
    return top_matches or _OFFICES


def _normalise_tokens(text: str) -> set[str]:
    cleaned = re.sub(r"[^a-z0-9\u0600-\u06FF]+", " ", text.lower())
    return {token for token in cleaned.split() if len(token) >= 3}


def _keyword_match_score(need_tokens: set[str], keywords: list[str]) -> int:
    score = 0
    for keyword in keywords:
        keyword_tokens = _normalise_tokens(keyword)
        if not keyword_tokens:
            continue
        shared = need_tokens.intersection(keyword_tokens)
        if shared:
            score += len(shared) * 3
        for token in need_tokens:
            if token in keyword or keyword in token:
                score += 1
    return score


def _distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    earth_radius_km = 6371.0
    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)
    a = (
        sin(dlat / 2) ** 2
        + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2) ** 2
    )
    return 2 * earth_radius_km * asin(sqrt(a))
