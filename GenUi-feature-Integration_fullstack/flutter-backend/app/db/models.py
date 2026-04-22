"""
db/models.py — SQLAlchemy ORM Models

Defines all database tables using SQLAlchemy 2.x declarative style
with full async support. All timestamps are stored as UTC.
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import (
    DateTime,
    ForeignKey,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


def utcnow() -> datetime:
    """Return the current UTC datetime (timezone-aware)."""
    return datetime.now(timezone.utc)


class Base(DeclarativeBase):
    """Abstract base class shared by all ORM models."""
    pass


# ── Users ──────────────────────────────────────────────────────────────────────

class User(Base):
    """
    Represents a registered application user.
    The firebase_uid field links this row to a Firebase Auth identity.
    """
    __tablename__ = "users"
    __table_args__ = (
        UniqueConstraint("firebase_uid", name="uq_users_firebase_uid"),
        UniqueConstraint("email", name="uq_users_email"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    firebase_uid: Mapped[str] = mapped_column(String(128), nullable=False, index=True)
    email: Mapped[Optional[str]] = mapped_column(String(320), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, server_default=func.now()
    )

    # Relationships
    chat_history: Mapped[list["ChatHistory"]] = relationship(
        "ChatHistory", back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} firebase_uid={self.firebase_uid}>"


# ── Chat History ───────────────────────────────────────────────────────────────

class ChatHistory(Base):
    """
    Persists every user–AI exchange.
    ai_response stores the raw validated JSON string returned to Flutter.
    """
    __tablename__ = "chat_history"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_message: Mapped[str] = mapped_column(Text, nullable=False)
    ai_response: Mapped[str] = mapped_column(Text, nullable=False)  # JSON string
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, server_default=func.now()
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="chat_history")

    def __repr__(self) -> str:
        return f"<ChatHistory id={self.id} user_id={self.user_id}>"


# ── Categories ─────────────────────────────────────────────────────────────────

class Category(Base):
    """
    Taxonomy of bureaucratic procedure categories shown in the Flutter UI.
    Names are stored in all three supported languages.
    """
    __tablename__ = "categories"
    __table_args__ = (
        UniqueConstraint("slug", name="uq_categories_slug"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    slug: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    name_ar: Mapped[str] = mapped_column(String(256), nullable=False)
    name_fr: Mapped[str] = mapped_column(String(256), nullable=False)
    name_en: Mapped[str] = mapped_column(String(256), nullable=False)
    icon: Mapped[str] = mapped_column(String(64), nullable=False)

    def __repr__(self) -> str:
        return f"<Category slug={self.slug}>"
