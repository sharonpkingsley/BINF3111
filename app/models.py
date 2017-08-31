from app import db


class Keyword(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    drug_a = db.Column(db.String(64), index=True)
    drug_b = db.Column(db.String(64), index=True)
    evidence = db.Column(db.String(64), index=True)
    value = db.Column(db.Float(16), index=True)

    def __repr__(self):
        return '<Keyword %r>' % (self.drug_a)

