#ifndef SETTINGS_H
#define SETTINGS_H

#include <QSettings>

class settings : public QObject
{
    Q_OBJECT

public:
    settings();

    int getHighScore();
    void setHighScore(int value);
    Q_PROPERTY(int highScore READ getHighScore WRITE setHighScore NOTIFY highScoreChanged)

signals:
    void highScoreChanged();

private:
    int highScore;
    QSettings setts;
};

#endif // SETTINGS_H
