<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260101000000 extends AbstractMigration
{
    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE category (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(80) NOT NULL, PRIMARY KEY(id))');
        $this->addSql('CREATE TABLE product (id INT AUTO_INCREMENT NOT NULL, category_id INT NOT NULL, name VARCHAR(120) NOT NULL, price_in_cents INT NOT NULL, PRIMARY KEY(id))');
        $this->addSql('ALTER TABLE product ADD CONSTRAINT FK_PRODUCT_CATEGORY FOREIGN KEY (category_id) REFERENCES category (id)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE product');
        $this->addSql('DROP TABLE category');
    }
}
