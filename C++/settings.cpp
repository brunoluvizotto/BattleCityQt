#include "settings.h"

settings::settings()
{

}

void settings::setHighScore(int value)
{
    setts.setValue("highScore", value);
    emit highScoreChanged();
}

int settings::getHighScore()
{
    return setts.value("highScore", 0).toInt();
}
