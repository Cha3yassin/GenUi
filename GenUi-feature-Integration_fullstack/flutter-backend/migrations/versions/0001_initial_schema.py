"""
migrations/versions/0001_initial_schema.py — Initial Database Schema

Creates the three core tables:
  - users
  - chat_history
  - categories

Run with: alembic upgrade head
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# Revision identifiers
revision: str = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ── users ─────────────────────────────────────────────────────────────────
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("firebase_uid", sa.String(128), nullable=False),
        sa.Column("email", sa.String(320), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id", name="pk_users"),
        sa.UniqueConstraint("firebase_uid", name="uq_users_firebase_uid"),
        sa.UniqueConstraint("email", name="uq_users_email"),
    )
    op.create_index("ix_users_firebase_uid", "users", ["firebase_uid"])

    # ── chat_history ──────────────────────────────────────────────────────────
    op.create_table(
        "chat_history",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_message", sa.Text, nullable=False),
        sa.Column("ai_response", sa.Text, nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id", name="pk_chat_history"),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name="fk_chat_history_user_id",
            ondelete="CASCADE",
        ),
    )
    op.create_index("ix_chat_history_user_id", "chat_history", ["user_id"])

    # ── categories ────────────────────────────────────────────────────────────
    op.create_table(
        "categories",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("slug", sa.String(64), nullable=False),
        sa.Column("name_ar", sa.String(256), nullable=False),
        sa.Column("name_fr", sa.String(256), nullable=False),
        sa.Column("name_en", sa.String(256), nullable=False),
        sa.Column("icon", sa.String(64), nullable=False),
        sa.PrimaryKeyConstraint("id", name="pk_categories"),
        sa.UniqueConstraint("slug", name="uq_categories_slug"),
    )
    op.create_index("ix_categories_slug", "categories", ["slug"])


def downgrade() -> None:
    op.drop_index("ix_categories_slug", table_name="categories")
    op.drop_table("categories")
    op.drop_index("ix_chat_history_user_id", table_name="chat_history")
    op.drop_table("chat_history")
    op.drop_index("ix_users_firebase_uid", table_name="users")
    op.drop_table("users")
